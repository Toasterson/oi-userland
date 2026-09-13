# Run on OpenIndiana: PYTHONPATH=tools/python /usr/bin/python -m unittest discover -s tools/python/pkglint/tests
# SPDX-License-Identifier: CDDL-1.0
import builtins
import configparser
import unittest
from unittest.mock import Mock, patch

builtins._ = lambda message: message
from pkglint.userland import UserlandActionChecker


class RunpathTests(unittest.TestCase):
    def setUp(self):
        config = configparser.ConfigParser()
        config.add_section("pkglint")
        config.set("pkglint", "pkglint.exclude", "")
        self.checker = UserlandActionChecker(config)

    def check_path(self, bits, runpath, warned):
        engine = Mock()
        with patch("pkglint.userland.elf.get_info", return_value={"bits": bits}), \
             patch("pkglint.userland.elf.get_dynamic", return_value={"runpath": runpath}):
            self.checker._UserlandActionChecker__elf_runpath_check("binary", engine)
        self.assertEqual(engine.warning.called, warned, (bits, runpath))
        if warned:
            self.assertEqual(engine.warning.call_args.kwargs["msgid"], "userland.action001.3")

    def test_clang_layout(self):
        for path in ["/usr/clang/18/lib", "/usr/clang/21/lib", "/usr/clang/21/lib/"]:
            with self.subTest(path=path):
                self.check_path(64, path, False)
                self.check_path(32, path, True)

    def test_similar_paths_are_not_exempt(self):
        for path in ["/usr/clang/21/lib32", "/usr/clang/21/lib/32", "/usr/clang/21/libexec",
                     "/usr/clang/no-version/lib", "/opt/clang/21/lib", "/usr/lib"]:
            with self.subTest(path=path):
                self.check_path(64, path, True)
                self.check_path(32, path, False)

    def test_existing_architecture_paths(self):
        for path in ["/usr/lib/qt/6.11/lib/amd64", "/usr/lib/qt/6.11/lib/sparcv9", "$ORIGIN/64"]:
            with self.subTest(path=path):
                self.check_path(64, path, False)
                self.check_path(32, path, True)

    def test_mixed_runpath_still_checks_every_entry(self):
        self.check_path(64, "/usr/clang/21/lib:/usr/lib", True)


if __name__ == "__main__":
    unittest.main()
