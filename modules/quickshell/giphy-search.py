import argparse
import json
import re
import sys
import urllib.error
import urllib.parse
import urllib.request


SEARCH_URL = "https://giphy.com/search/"
USER_AGENT = (
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
)
FLIGHT_CHUNK = re.compile(r'self\.__next_f\.push\(\[1,("(?:[^"\\]|\\.)*")\]\)')
GIFS_KEY = '"initialGifs":'


def search(query, limit):
    request = urllib.request.Request(
        SEARCH_URL + urllib.parse.quote(query, safe=""),
        headers={
            "User-Agent": USER_AGENT,
            "Accept": "text/html,application/xhtml+xml",
            "Accept-Language": "en-US,en;q=0.9",
        },
    )
    with urllib.request.urlopen(request, timeout=15) as response:
        page = response.read(16 << 20).decode("utf-8", errors="replace")

    chunks = FLIGHT_CHUNK.findall(page)
    if not chunks:
        raise RuntimeError("no page data found; Giphy may have changed its layout")

    payload = "".join(json.loads(chunk) for chunk in chunks)
    start = payload.find(GIFS_KEY)
    if start < 0:
        raise RuntimeError("no results found; Giphy may have changed its layout")
    items, _ = json.JSONDecoder().raw_decode(payload[start + len(GIFS_KEY) :])

    results = []
    for item in items:
        images = item.get("images", {})
        original = images.get("original", {}).get("url", "")
        preview = images.get("fixed_width", {}).get("url", "")
        if not preview:
            preview = images.get("fixed_width_downsampled", {}).get("url", "")
        if original and preview:
            results.append(
                {
                    "title": item.get("title") or "Untitled GIF",
                    "url": original,
                    "preview": preview,
                }
            )
        if len(results) >= limit:
            break
    return results


def main():
    parser = argparse.ArgumentParser(description="Scrape Giphy search results as JSON")
    parser.add_argument("query")
    parser.add_argument("--limit", type=int, default=24, choices=range(1, 26))
    args = parser.parse_args()

    try:
        query = args.query.strip()
        print(json.dumps({"query": query, "results": search(query, args.limit)}))
    except (OSError, ValueError, RuntimeError, urllib.error.HTTPError) as error:
        print(f"Giphy search failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
