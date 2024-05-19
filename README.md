
## Flutter Demo : https://www.youtube.com/watch?v=VxpqJHFqxOA
## Qibla Demo : 

https://github.com/BrightProgrammer7/ASO-TEAM-G1/assets/125312216/bcb32799-aa9f-4c36-bf39-64545939f139

## VHDL Amélioration

## lAB 1 : Compteur de 2 bits

### Synthèse du code VHDL
La synthèse du code VHDL nous permet d’obtenir deux schémas : RTL et Technology. Le schéma RTL est celui qui se rapproche le plus du code VHDL. Il est composé de boîtes représentant des multiplicateurs, additionneurs, compteurs, etc. Ces boîtes peuvent être reliées entre elles par des portes logiques AND, OR, etc. On n'y voit pas de composants physiques. Voici le schéma RTL avec le code du reset synchrone :

![Schéma RTL](https://github.com/BrightProgrammer7/ASO-TEAM-G1/assets/107751911/d1a9577a-c6b3-434f-828a-33bf5d86da85) 
![Schéma RTL 2](https://github.com/BrightProgrammer7/ASO-TEAM-G1/assets/107751911/cdadc998-e654-4031-be54-7606013f3277)

### Simulation du circuit
Ensuite, nous effectuons la simulation du circuit grâce au logiciel. En faisant varier les deux signaux d’entrée, voici le résultat que nous obtenons.

Lors de la simulation avec l’horloge synchrone, on remarque que lorsque le reset est activé, on doit attendre que le signal d’entrée PB 0 soit passé à ‘1’ pour que le compteur repasse à 0. Tant que le signal d’entrée PB 0 n’est pas passé à 1, le reset ne prend pas effet. Ce n’est pas le cas avec un reset asynchrone, dont voici la simulation :

![Simulation Reset Asynchrone](https://github.com/BrightProgrammer7/ASO-TEAM-G1/assets/107751911/0cc61ad5-137a-4e6b-8200-edaec0d0598c)

Ici, on peut voir que le reset prend effet dès son activation, sans besoin que PB 0 soit activé.

## Lab 2: Détecteur de code

### Objectif
Dans ce , nous réaliserons un détecteur pour le code 11010. Si le code est détecté, une alarme est activée. 

### Utilisation des signaux
- **BP 0** pour l’horloge
- **SW 0** pour la ligne de transmission permettant de rentrer 0 ou 1
- **LED 0** pour symboliser l’alarme
- **LED 7654** pour afficher l’état de la machine à états

### Synthèse du code VHDL
Voici le schéma RTL obtenu après synthèse du code VHDL :

![Schéma RTL Détecteur de Code](https://github.com/BrightProgrammer7/ASO-TEAM-G1/assets/107751911/2106662e-3333-4790-a68d-b9cbae1b02e1)
![Schéma RTL Détecteur de Code 2](https://github.com/BrightProgrammer7/ASO-TEAM-G1/assets/107751911/853116f9-d1e8-4428-ae0b-928c6490d17b)

### Simulation du circuit
Lors de la simulation, voici ce que nous avons obtenu :

![Simulation Détecteur de Code](https://github.com/BrightProgrammer7/ASO-TEAM-G1/assets/107751911/c2031f84-99cb-4ea1-8f52-504a0e0026b5)

On remarque bien que dès qu’une fausse entrée est entrée, la variable d’état retombe à 0.

---

Ce dépôt GitHub contient les fichiers VHDL nécessaires pour la création et la simulation d'un compteur de 2 bits ainsi que d'un détecteur de code pour le code 11010. Vous trouverez également des captures d'écran des schémas RTL et des résultats de simulation.
