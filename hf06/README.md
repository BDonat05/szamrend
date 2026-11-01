# HF06  
## set -euo pipefail  
 - `set -e`: A shell azonnal kilep, ha akarmelyik futtatott program nem-nulla exit code-dal fejezodik be. Parancssoros shell hasznalatnal nincs bekapcsolva, hiszen nem akarunk kilepni a shellbol, ha hibat ad a parancs amit futtatunk, vagy elirunk valamit
 - `set -u`: A shell kilep, ha nem letezo valtozora hivatkozunk a scriptben. Hasznos, mert felhivja a figyelmet az elorasokra, nem hozunk letre uj valtozokat, ha veletlen elirjuk a nevuket
 - `set -o pipefail`: Ha egy pipeline-ban van hiba (azaz nem-nulla exit code), akkor az az exit code legyen a teljes pipeline exit code-ja. Hasznalataval a hibas szamitasok nem folynak tovabb a pipelineokon

## Csapda elkerulese  
Annak erdekeben, hogy a curl hibai eseten folytatodjon a script, es bekapcsolva maradjon a set -e, minden curl hivast egy if statement-be wrappeltem.

## Egy futas logja  
23:15:37 Attempt 1/3 fetch from https://api.frankfurter.dev/v1/latest  
23:15:38 Download successful  
23:15:38 Attempt 1/3 fetch from https://api.open-meteo.com/v1/forecast?latitude=47.5&longitude=19.05&current=temperature_2m  
23:15:38 Download successful  
23:15:38 Attempt 1/3 fetch from https://date.nager.at/api/v3/PublicHolidays/2026/HU  
23:15:38 Download successful  
23:15:38 Attempt 1/3 fetch from https://httpbin.org/status/500  
curl: (22) The requested URL returned error: 500  
23:15:39 Request failed. Retrying in 1s  
23:15:40 Attempt 2/3 fetch from https://httpbin.org/status/500  
curl: (22) The requested URL returned error: 500  
23:15:40 Request failed. Retrying in 2s  
23:15:42 Attempt 3/3 fetch from https://httpbin.org/status/500  
curl: (22) The requested URL returned error: 500  
23:15:43 Download failed from https://httpbin.org/status/500  
23:15:43 Attempt 1/3 fetch from https://httpbin.org/delay/10  
23:15:54 Download successful  
23:15:54 Attempt 1/3 fetch from https://ez.a.domain.biztosan.nem.letezik/valami.json  
curl: (6) Could not resolve host: ez.a.domain.biztosan.nem.letezik  
23:15:54 Request failed. Retrying in 1s  
23:15:55 Attempt 2/3 fetch from https://ez.a.domain.biztosan.nem.letezik/valami.json  
curl: (6) Could not resolve host: ez.a.domain.biztosan.nem.letezik  
23:15:55 Request failed. Retrying in 2s  
23:15:57 Attempt 3/3 fetch from https://ez.a.domain.biztosan.nem.letezik/valami.json  
curl: (6) Could not resolve host: ez.a.domain.biztosan.nem.letezik  
23:15:57 Download failed from https://ez.a.domain.biztosan.nem.letezik/valami.json  
