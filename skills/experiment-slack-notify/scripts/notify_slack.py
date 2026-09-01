#!/usr/bin/env python3
"""Send a concise Slack notification using the configured experiment webhook."""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request


WEBHOOK_ENV = "SHOWER_THOUGHTS_SLACK_WEBHOOK_URL"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("message", help="Message text to send to Slack")
    parser.add_argument(
        "--username",
        default=None,
        help="Optional Slack username override for webhook integrations that allow it",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    webhook = os.environ.get(WEBHOOK_ENV)
    if not webhook:
        print(f"Missing required env var: {WEBHOOK_ENV}", file=sys.stderr)
        return 2

    # Shell callers often pass a readable one-line argument containing `\n`.
    # Slack does not expand those escapes, so normalize them here.
    message = args.message.replace("\\n", "\n")
    payload = {"text": message}
    if args.username:
        payload["username"] = args.username

    request = urllib.request.Request(
        webhook,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            body = response.read().decode("utf-8", errors="replace")
            if response.status >= 400 or body.strip() != "ok":
                print(f"Slack rejected message: status={response.status} body={body}", file=sys.stderr)
                return 1
    except urllib.error.URLError as exc:
        print(f"Slack notification failed: {exc}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
