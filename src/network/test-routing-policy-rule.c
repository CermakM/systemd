/***
  SPDX-License-Identifier: LGPL-2.1+

  This file is part of systemd.

  Copyright 2017 Zbigniew Jędrzejewski-Szmek

  systemd is free software; you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by
  the Free Software Foundation; either version 2.1 of the License, or
  (at your option) any later version.

  systemd is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with systemd; If not, see <http://www.gnu.org/licenses/>.
***/

#include "fd-util.h"
#include "fileio.h"
#include "log.h"
#include "macro.h"
#include "network-internal.h"
#include "networkd-manager.h"
#include "string-util.h"

static void test_rule_serialization(const char *title, const char *ruleset, const char *expected) {
        char pattern[] = "/tmp/systemd-test-routing-policy-rule.XXXXXX",
             pattern2[] = "/tmp/systemd-test-routing-policy-rule.XXXXXX",
             pattern3[] = "/tmp/systemd-test-routing-policy-rule.XXXXXX";
        const char *cmd;
        int fd, fd2, fd3;
        _cleanup_fclose_ FILE *f = NULL, *f2 = NULL, *f3 = NULL;
        Set *rules = NULL;
        _cleanup_free_ char *buf = NULL;
        size_t buf_size;

        log_info("========== %s ==========", title);
        log_info("put:\n%s\n", ruleset);

        assert_se((fd = mkostemp_safe(pattern)) >= 0);
        assert_se(f = fdopen(fd, "a+e"));
        assert_se(write_string_stream(f, ruleset, 0) == 0);

        assert_se(routing_policy_load_rules(pattern, &rules) == 0);

        assert_se((fd2 = mkostemp_safe(pattern2)) >= 0);
        assert_se(f2 = fdopen(fd2, "a+e"));

        assert_se(routing_policy_serialize_rules(rules, f2) == 0);
        assert_se(fflush_and_check(f2) == 0);

        assert_se(read_full_file(pattern2, &buf, &buf_size) == 0);

        log_info("got:\n%s", buf);

        assert_se((fd3 = mkostemp_safe(pattern3)) >= 0);
        assert_se(f3 = fdopen(fd3, "we"));
        assert_se(write_string_stream(f3, expected ?: ruleset, 0) == 0);

        cmd = strjoina("diff -u ", pattern3, " ", pattern2);
        log_info("$ %s", cmd);
        assert_se(system(cmd) == 0);

        set_free_with_destructor(rules, routing_policy_rule_free);
}

int main(int argc, char **argv) {
        _cleanup_free_ char *p = NULL;

        log_set_max_level(LOG_DEBUG);
        log_parse_environment();
        log_open();

        test_rule_serialization("basic parsing",
                                "RULE=from=1.2.3.4/32 to=2.3.4.5/32 tos=5 fwmark=1/2 table=10", NULL);

        test_rule_serialization("ignored values",
                                "RULE=something=to=ignore from=1.2.3.4/32 from=1.2.3.4/32"
                                "   \t  to=2.3.4.5/24 to=2.3.4.5/32 tos=5 fwmark=2 fwmark=1 table=10 table=20",
                                "RULE=from=1.2.3.4/32"
                                " to=2.3.4.5/32 tos=5 fwmark=1/0 table=20");

        test_rule_serialization("ipv6",
                                "RULE=from=1::2/64 to=2::3/64 table=6", NULL);

        assert_se(asprintf(&p, "RULE=from=1::2/64 to=2::3/64 table=%d", RT_TABLE_MAIN) >= 0);
        test_rule_serialization("default table",
                                "RULE=from=1::2/64 to=2::3/64", p);

        test_rule_serialization("incoming interface",
                                "RULE=from=1::2/64 to=2::3/64 table=1 iif=lo",
                                "RULE=from=1::2/64 to=2::3/64 iif=lo table=1");

        test_rule_serialization("outgoing interface",
                                "RULE=from=1::2/64 to=2::3/64 oif=eth0 table=1", NULL);

        test_rule_serialization("freeing interface names",
                                "RULE=from=1::2/64 to=2::3/64 iif=e0 iif=e1 oif=e0 oif=e1 table=1",
                                "RULE=from=1::2/64 to=2::3/64 iif=e1 oif=e1 table=1");

        return 0;
}
