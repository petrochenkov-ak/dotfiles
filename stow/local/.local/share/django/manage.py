#!/usr/bin/env python
import sys

from configurations.management import execute_from_command_line


def main():
    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
