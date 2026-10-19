# Generuje index.html (galeria) i piktogramy-dostepnosci-svg.zip na podstawie plików z katalogu svg/.
# Uruchomienie z katalogu głównego repozytorium: pwsh scripts/build.ps1

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = [Text.UTF8Encoding]::new($false)
$nfc = [Text.NormalizationForm]::FormC

$files = Get-ChildItem (Join-Path $root 'svg') -Filter *.svg | Sort-Object { $_.Name.Normalize($nfc) }

$items = foreach ($f in $files) {
    $name = $f.Name.Normalize($nfc)
    $title = [IO.Path]::GetFileNameWithoutExtension($name)
    $href = 'svg/' + [uri]::EscapeDataString($name)
    $t = [System.Net.WebUtility]::HtmlEncode($title)
    @"
      <li>
        <figure>
          <img src="$href" alt="" width="96" height="96" loading="lazy">
          <figcaption>$t</figcaption>
        </figure>
        <a class="download" href="$href" download="$([System.Net.WebUtility]::HtmlEncode($name))">Pobierz SVG<span class="sr-only">: $t</span></a>
      </li>
"@
}

$page = @"
<!doctype html>
<html lang="pl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Piktogramy dostępności</title>
  <meta name="description" content="Piktogramy dostępności w formacie SVG do pobrania. Licencja CC BY-SA 4.0.">
  <style>
    :root {
      --bg: #ffffff;
      --fg: #1d1d1b;
      --muted: #4a4a47;
      --card: #f4f4f2;
      --border: #c9c9c4;
      --link: #0b4fa3;
      --focus: #b35c00;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --bg: #161615;
        --fg: #f2f2ee;
        --muted: #c4c4be;
        --card: #232321;
        --border: #55554f;
        --link: #8fc0ff;
        --focus: #ffb454;
      }
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: var(--bg);
      color: var(--fg);
      font: 1.125rem/1.55 system-ui, -apple-system, "Segoe UI", sans-serif;
    }
    .wrap { max-width: 70rem; margin: 0 auto; padding: 0 1rem; }
    header, main, footer { padding-block: 1.5rem; }
    h1 { font-size: 2rem; line-height: 1.2; margin: 0 0 .5rem; }
    h2 { font-size: 1.5rem; margin: 2rem 0 .75rem; }
    a { color: var(--link); }
    a:focus-visible { outline: 3px solid var(--focus); outline-offset: 3px; }
    .button {
      display: inline-block;
      padding: .6rem 1.1rem;
      border: 2px solid var(--link);
      border-radius: .4rem;
      font-weight: 600;
      text-decoration: none;
    }
    .button:hover { background: var(--card); }
    ul.grid {
      list-style: none;
      margin: 0;
      padding: 0;
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(11rem, 1fr));
      gap: 1rem;
    }
    ul.grid li {
      background: var(--card);
      border: 1px solid var(--border);
      border-radius: .5rem;
      padding: 1rem;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: .75rem;
      text-align: center;
    }
    figure { margin: 0; display: flex; flex-direction: column; align-items: center; gap: .75rem; flex: 1; }
    figcaption { font-size: 1rem; line-height: 1.3; }
    /* Piktogramy są czarne i przezroczyste, więc w trybie ciemnym dostają jasne tło. */
    img { background: #fff; border-radius: .35rem; padding: .35rem; }
    .download { font-size: 1rem; font-weight: 600; }
    .sr-only {
      position: absolute; width: 1px; height: 1px; margin: -1px; padding: 0;
      overflow: hidden; clip-path: inset(50%); white-space: nowrap; border: 0;
    }
    footer { border-top: 1px solid var(--border); color: var(--muted); font-size: 1rem; }
    footer a { color: var(--link); }
  </style>
</head>
<body>
  <header class="wrap">
    <h1>Piktogramy dostępności</h1>
    <p>Zestaw $($files.Count) piktogramów w formacie SVG. Możesz pobrać pojedyncze pliki albo cały zestaw.</p>
    <p><a class="button" href="piktogramy-dostepnosci-svg.zip" download>Pobierz wszystkie (ZIP)</a></p>
  </header>

  <main class="wrap">
    <h2>Lista piktogramów</h2>
    <ul class="grid">
$($items -join "`n")
    </ul>

    <h2 id="licencja">Autorstwo i licencja</h2>
    <p>
      Autor piktogramów: Tomasz Grabowski. Prawa autorskie: Fundacja Kultury Bez Barier.
      Piktogramy są dostępne na licencji
      <a href="https://creativecommons.org/licenses/by-sa/4.0/legalcode.pl">Creative Commons Uznanie autorstwa – Na tych samych warunkach 4.0 (CC BY-SA 4.0)</a>.
    </p>
    <p>
      Przy udostępnianiu podaj autora i właściciela praw autorskich, wskaż licencję
      (https://creativecommons.org/licenses/by-sa/4.0/legalcode.pl) i oznacz wprowadzone zmiany.
      Zmodyfikowane wersje udostępniaj na tej samej licencji.
    </p>
    <p>
      W plikach SVG dodano element <code>title</code>, metadane, atrybuty <code>role</code> i <code>aria-labelledby</code>
      oraz unikalne identyfikatory i nazwy klas. Kształty piktogramów nie zostały zmienione.
    </p>
  </main>

  <footer class="wrap">
    <p><a href="https://github.com/JacZad/piktogramy-dostepnosci">Repozytorium na GitHubie</a></p>
  </footer>
</body>
</html>
"@
[IO.File]::WriteAllText((Join-Path $root 'index.html'), ($page -replace "`r`n", "`n"), $utf8)

# ZIP: pliki SVG i licencja.
$zip = Join-Path $root 'piktogramy-dostepnosci-svg.zip'
if (Test-Path $zip) { Remove-Item $zip }
Compress-Archive -Path (Join-Path $root 'svg'), (Join-Path $root 'LICENSE') -DestinationPath $zip
Write-Host "Gotowe: index.html, $(Split-Path -Leaf $zip) ($($files.Count) piktogramów)"
