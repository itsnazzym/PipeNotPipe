# Développement

## Première installation

```powershell
git clone https://github.com/itsnazzym/PipeNotPipe.git
cd PipeNotPipe
.\scripts\setup.ps1 -InstallToolchain
.\scripts\build.ps1
```

Installe Android Studio et son SDK avant ces commandes. `setup.ps1` utilise les révisions épinglées du client et de l'extracteur, prépare une branche de travail et ajoute les remotes officiels `upstream`. Il ne fait aucun reset ni merge. Sous Linux, configure Java 25 et ANDROID_HOME puis utilise le wrapper dans `PipePipeClient` ; les scripts de validation sont aussi compatibles avec PowerShell 7.

Le setup renseigne le JDK 25 dans le fichier local ignoré `.gradle/config.properties`. Android Studio peut l'utiliser avec le réglage Gradle JDK `GRADLE_LOCAL_JAVA_HOME`. Si l'IDE impose son JDK intégré, sélectionne Java 25 dans Settings > Build, Execution, Deployment > Build Tools > Gradle > Gradle JDK.

## Où intervenir

Pour les écrans : `PipePipeClient/app/src/main/java/org/schabi/newpipe/fragments`, `local`, `settings`, `views`, et `app/src/main/res`.

Pour la lecture : `PipePipeClient/app/src/main/java/org/schabi/newpipe/player`. Pour les téléchargements : `org/schabi/newpipe/download` et `us/shandian/giga`.

Pour les règles de cache : `core/cache/src/main/java/dev/pipenotpipe/core/cache`. Pour le chargement des informations : `data/media/src/main/java/dev/pipenotpipe/data/media`.

Pour YouTube et les autres sources : `PipePipeExtractor/extractor/src/main/java/org/schabi/newpipe/extractor/services`.

## Enregistrer les modifications

Le dépôt principal ne contient pas directement les fichiers de ses sous-modules. Exemple après modification du client :

```powershell
git -C PipePipeClient add app core data config gradle settings.gradle
git -C PipePipeClient commit -m "Describe the client change"
git -C PipePipeClient push origin HEAD

git add PipePipeClient
git commit -m "Update client revision"
git push origin HEAD
```

Si tu travailles sur une branche créée par `setup.ps1`, la commande `push origin HEAD` publie cette branche. Fais ensuite une PR vers `main` dans ton fork et mets à jour la révision du dépôt principal.

Pour l'extracteur, applique la même séquence à `PipePipeExtractor`. N'enregistre pas de keystore, de mot de passe, de `local.properties`, d'APK ou de cache Gradle dans Git.

## Récupérer les changements officiels

```powershell
git fetch upstream
git -C PipePipeClient fetch upstream
git -C PipePipeExtractor fetch upstream

git -C PipePipeClient log --oneline HEAD..upstream/dev
git -C PipePipeExtractor log --oneline HEAD..upstream/main
```

Intègre ensuite les changements choisis dans une branche, résous les conflits, puis relance la validation. N'utilise pas `git submodule update --remote` comme mise à jour automatique : cela peut changer la combinaison client/extracteur sans validation.

## Vérifications rapides

```powershell
.\scripts\check-architecture.ps1
cd PipePipeClient
.\gradlew.bat :core:cache:test :data:media:test
```

Pour ces commandes Gradle directes, JAVA_HOME doit pointer sur Java 25. `scripts/build.ps1` détecte le JDK installé par le setup et configure le SDK automatiquement pour sa propre exécution.

`build.ps1 -SkipLint` sert aux itérations locales après une validation complète. La CI exécute les 15 tests, compile les quatre APK debug et conserve les rapports Lint. La configuration non bloquante du Lint hérité est documentée ; un job vert ne signifie pas que cette dette a été résolue.

## Releases

Le nom et l'identifiant installable se règlent dans `config/fork.properties`. Incrémente `app.versionCode` à chaque publication. Garde un `app.versionName` compatible avec le parseur hérité, par exemple `5.4.1` ou `5.4.1-beta1`.

Une release exige une clé de signature durable et les quatre variables indiquées dans le README. `release.sh` et `build.ps1 -Release` compilent seulement ; ils ne publient pas automatiquement. Active `app.updates.enabled` seulement après avoir publié des APK signés compatibles dans les releases du dépôt configuré. Les mises à jour debug doivent continuer à utiliser la clé debug correspondante.
