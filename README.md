# Skrypt lab1

W projekcie wykorzystujemy powłokę bash oraz narzędzie gcloud.

Głównym wejściem programu jest skrypt `run.sh`, która za argumenty przyjmuje:
- nazwę projektu na serwisie google cloud,
- numer konfiguracji (1, 3, 4) lub polecenie `clean`,
- argumenty specyficzne dla danych konfiguracji,

Przykłady uruchomienia każdej konfiguracji i czyszczenia są dostępne w swoich własnych skryptach:
- `example1.sh`
- `example3.sh`
- `example4.sh`
- `clean.sh`

Kilka szczegółów implementacji:
- indywidualne konfiguracje mają swoje własne skrypty, które przyjmują różne argumenty (folder `configs`)
- maszyny pobierane są z chmury za pomocą nazwy projektu, wybierane są poprzez podanie indeksu zaczynając od 1 (skrypt `machine_info.sh`)
- skrypty z katalogu `remote_scripts` są przesyłane na maszynę, gdzie jeden z nich zostanie uruchomiony z parametrami (skrypt `run_remotely.sh`)
- skrypty są przesyłane w ramach każdego obrazu konfiguracji
