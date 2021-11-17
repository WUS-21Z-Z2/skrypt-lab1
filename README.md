# Skrypt lab1

W projekcie wykorzystujemy powłokę bash oraz narzędzie gcloud.  
Zakłada się, że "czyste" maszyny mają już zainstalowane oprogramowanie Docker. Ponadto wymagane jest, aby użytkownik skonfigurował regułę zapory sieciowej przepuszczającą ruch przychodzący na portach powiązanych z serwisami Angular oraz REST (w konfiguracji 4: load balancer).

Głównym wejściem programu jest skrypt `run.sh`, która za argumenty przyjmuje:
- numer konfiguracji (1, 3, 4) lub polecenie `clean`,
- nazwę projektu na serwisie google cloud,
- (opcjonalnie) argumenty specyficzne dla danych konfiguracji.

Przykłady uruchomienia każdej konfiguracji i czyszczenia są dostępne w swoich własnych skryptach:
- `example1.sh`
- `example3.sh`
- `example4.sh`
- `clean.sh`

Kilka szczegółów implementacji:
- indywidualne konfiguracje mają swoje własne skrypty, które przyjmują różne argumenty (folder `configs`)
- lista maszyn pobierana jest z chmury za pomocą nazwy projektu, instancje wybierane są poprzez podanie indeksu zaczynając od 1 (skrypt `machine_info.sh`)
- skrypty z katalogu `remote_scripts` są przesyłane na maszynę, gdzie następnie jeden z nich jest uruchamiany z odpowiednimi parametrami (skrypt `run_remotely.sh`)
- skrypty są przesyłane w ramach każdego obrazu konfiguracji
- skrypty powinny być przesyłane z platformy uniksowej, aby uniknąć problemów z sekwencją zakończenia linii
- po wdrożeniu każdej konfiguracji uruchamiane są podstawowe testy front-endu i REST API

Wykorzystywane w konfiguracji obrazy pobierane są z witryny dockerhub, gdzie trafiły po zbudowaniu ich na podstawie dostępnych w pozostałych repozytoriach grupy źródeł.

| Wykorzystywany obraz | Repozytorium źródłowe |
| ------ | ------ |
| [dove6/spring-petclinic-angular](https://hub.docker.com/r/dove6/spring-petclinic-angular)       | [wus-lab-zesp-2/spring-petclinic-angular](https://gitlab-stud.elka.pw.edu.pl/wus-lab-zesp-2/spring-petclinic-angular) |
| [dove6/spring-petclinic-rest-mysql](https://hub.docker.com/r/dove6/spring-petclinic-rest-mysql) | [wus-lab-zesp-2/spring-petclinic-rest](https://gitlab-stud.elka.pw.edu.pl/wus-lab-zesp-2/spring-petclinic-rest) |
| [dove6/nginx-load-balancer](https://hub.docker.com/r/dove6/nginx-load-balancer)                 | [wus-lab-zesp-2/nginx-load-balancer](https://gitlab-stud.elka.pw.edu.pl/wus-lab-zesp-2/nginx-load-balancer) |
| [dove6/mysql-master](https://hub.docker.com/r/dove6/mysql-master)                               | [wus-lab-zesp-2/mysql-master](https://gitlab-stud.elka.pw.edu.pl/wus-lab-zesp-2/mysql-master) |
| [dove6/mysql-slave](https://hub.docker.com/r/dove6/mysql-slave)                                 | [wus-lab-zesp-2/mysql-slave](https://gitlab-stud.elka.pw.edu.pl/wus-lab-zesp-2/mysql-slave) |
