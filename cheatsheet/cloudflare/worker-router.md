# Cloudflare Worker 라우터 — 단축 도메인 자동화

`handy.jeongph.dev/<name>` 요청을 GitHub raw 스크립트로 연결하는 Worker.
**한 번 배포하면 새 스크립트를 추가해도 코드를 다시 건드릴 필요가 없다** — 경로의 `<name>`을 폴더 구조에 그대로 매핑하기 때문.

매핑 규칙:

```
handy.jeongph.dev/<name>
   → raw.githubusercontent.com/jeongph/handy/main/shell/<name>/<name>.sh
```

전제: `shell/<name>/<name>.sh` (폴더명 = 진입점 `.sh`명) 규칙. 이 레포는 이미 이 규칙을 따른다.

## Worker 코드

```js
// handy.jeongph.dev/<name> → raw.githubusercontent.com/jeongph/handy/main/shell/<name>/<name>.sh
export default {
  async fetch(request) {
    const path = new URL(request.url).pathname
      .replace(/^\//, "")
      .replace(/\/$/, "");

    if (!path) {
      return new Response("usage: curl -fsSL https://handy.jeongph.dev/<script-name>\n", {
        status: 400,
      });
    }

    const rawUrl = `https://raw.githubusercontent.com/jeongph/handy/main/shell/${path}/${path}.sh`;
    const upstream = await fetch(rawUrl, { cf: { cacheTtl: 300 } });

    if (!upstream.ok) {
      return new Response(`not found: ${path}\n`, { status: upstream.status });
    }

    return new Response(upstream.body, {
      status: 200,
      headers: { "content-type": "text/x-shellscript; charset=utf-8" },
    });
  },
};
```

- 빈 경로(`/`)는 사용법 안내(400)
- 없는 스크립트는 GitHub 상태코드 그대로(보통 404)
- `cacheTtl: 300` — 5분 캐시로 GitHub 부하·지연 감소
- `content-type`을 셸 스크립트로 명시

## 대시보드 배포 (도구 설치 불필요)

> 전부 브라우저에서 진행한다. `wrangler`·`npm` 불필요.

1. **Cloudflare 대시보드** 로그인 → 왼쪽 메뉴 **Workers & Pages**
2. **Create** → **Create Worker** → 이름을 `handy-router` 로 두고 **Deploy** (기본 템플릿으로 일단 배포)
3. 배포된 Worker → **Edit code** → 기본 코드를 지우고 위 **Worker 코드** 붙여넣기 → **Deploy**
4. Worker → **Settings** → **Domains & Routes** → **Add** → **Custom Domain** 선택
   - **Domain**: `handy.jeongph.dev`
   - 추가하면 Cloudflare가 **DNS 레코드를 자동 생성**한다 (별도 DNS 등록 불필요)
   > `jeongph.dev` zone이 이미 Cloudflare에 있어야 한다 (있음). Custom Domain은 서브도메인 전체를 이 Worker로 연결한다.

## 테스트

```sh
# raw 스크립트 내용이 그대로 나오면 성공
curl -fsSL https://handy.jeongph.dev/setup-alias | head

# 없는 이름은 404
curl -i https://handy.jeongph.dev/nope
```

문제가 있으면 Worker의 **Logs**(실시간 로그) 탭에서 요청을 확인한다.

## 새 스크립트를 추가할 때

1. `shell/<new-name>/<new-name>.sh` + `README.md` 생성 (기존 패턴 그대로)
2. `main`에 머지
3. 끝 — `handy.jeongph.dev/<new-name>` 이 자동으로 동작 (**Worker 수정 불필요**)

## 비용

개인 트래픽은 Workers 무료 티어(하루 10만 요청) 안이라 **무료**.
