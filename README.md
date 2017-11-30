## Docker image voor Jenkins slave met Libsodium

Het maken/update van de image doe je met:
```console
$ docker build --no-cache -t usefdynamo/jenkins-jnlp-slave:0.5 .
```

Om dit image beschikbaar te hebben in de k8s omgeving(en) moet het nog gepushed worden naar de usefdynamo repository:
```console
$ docker push usefdynamo/jenkins-jnlp-slave:0.5
```

*Check het versie nummer voordat je bovenstaande commando's uitvoert! De bedoeling is dat deze repo automatisch gebouwd gaat worden middels Docker Hub of Quay.io. Op dit moment is het nog niet zover en moeten wijzigingen in deze repo's handmatig gepushed worden.*