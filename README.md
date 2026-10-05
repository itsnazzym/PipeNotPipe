# PipeNotPipe

Ton fork de [PipePipe](https://github.com/InfinityLoop1308/PipePipe), basé sur la version 5.4.0. L'application Android et l'extracteur sont modifiables dans tes propres dépôts. Les sources, l'historique et les licences GPL sont conservés.

## Démarrer sous Windows

Java 25 et un SDK Android sont requis. Le script peut installer Temurin 25 ; le SDK se prépare avec Android Studio. Gradle installe la plateforme Android nécessaire si les licences du SDK ont été acceptées.

```powershell
.\scripts\setup.ps1 -InstallToolchain
.\scripts\build.ps1
```

Ouvre **PipePipeClient** dans Android Studio, sélectionne le module `app`, puis lance la variante `debug`. Le SDK Android habituel est détecté automatiquement. Sur une autre machine, renseigne `ANDROID_HOME` si nécessaire.

Les APK et leurs empreintes SHA-256 sont copiés dans `artifacts/`. L'application s'appelle **PipeNotPipe Debug**, avec l'identifiant `dev.pipenotpipe.app.debug`. Elle peut cohabiter avec PipePipe, avec ses propres données.

## Modifier le projet

| Emplacement | Responsabilité |
| --- | --- |
| `PipePipeClient/config/fork.properties` | Nom, identifiant, version, dépôt de mises à jour et SDK |
| `PipePipeClient/app` | Écrans, lecteur, téléchargements, base locale et intégration Android existants |
| `PipePipeClient/core/cache` | Cache LRU et expiration, sans Android ni extracteur |
| `PipePipeClient/data/media` | Chargement avec cache, rafraîchissement et alias des URL |
| `PipePipeExtractor/extractor` | Extraction des informations et des flux YouTube et autres services |
| `docs/ARCHITECTURE.md` | Architecture actuelle, contraintes et prochaines migrations |
| `docs/DEVELOPMENT.md` | Travail quotidien, Git, compilation et synchronisation upstream |

Les deux nouveaux modules sont **utilisés par l'application**, via `InfoCache` et `ExtractorHelper`. Le lecteur et les écrans existants continuent à fonctionner avec leurs interfaces habituelles. L'application héritée n'est pas encore intégralement modularisée.

## Dépôts

- Orchestration et documentation : [itsnazzym/PipeNotPipe](https://github.com/itsnazzym/PipeNotPipe)
- Client Android : [itsnazzym/PipeNotPipeClient](https://github.com/itsnazzym/PipeNotPipeClient)
- Extracteur : [itsnazzym/PipeNotPipeExtractor](https://github.com/itsnazzym/PipeNotPipeExtractor)

Chaque sous-module possède son historique Git. Enregistre et pousse le client ou l'extracteur **avant** le dépôt principal, qui conserve leurs révisions exactes. `setup.ps1` prépare des branches éditables sans remplacer les révisions épinglées.

## Vérification et publication

`build.ps1` vérifie les dépendances des modules, exécute les tests du cache et du chargement, compile les APK et lance Android Lint. Le code hérité conserve sa configuration Lint non bloquante ; consulte les rapports, même si la compilation réussit.

Les mises à jour automatiques du fork sont désactivées tant qu'aucune release signée n'est publiée. Pour une release, configure les variables de signature `KEY_PATH`, `KEY_STORE_PASSWORD`, `KEY_ALIAS` et `KEY_PASSWORD`, puis lance `scripts/build.ps1 -Release`. Conserve la même clé pour les versions suivantes. Le script de release ne pousse aucun dépôt et ne publie aucun fichier automatiquement.

Le projet dérive de PipePipe et de NewPipe. Les attributions et licences restent dans les sources et dans `LICENSE`. Le README PipePipe original est conservé dans [docs/UPSTREAM.md](docs/UPSTREAM.md).
