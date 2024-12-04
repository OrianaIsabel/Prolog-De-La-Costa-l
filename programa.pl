% Aquí va el código.
comida(hamburguesa, 2000).
comida(pancho, 1500).
comida(lomito, 2500).
comida(caramelos, 0).

puesto(hamburgueseria, hamburguesa).
puesto(pancheria, pancho).
puesto(sangucheria, lomito).
puesto(dulceria, caramelos).

atraccion(autitos, tranquila(todos)).
atraccion(casaEmbrujada, tranquila(todos)).
atraccion(laberinto, tranquila(todos)).
atraccion(tobogan, tranquila(chicos)).
atraccion(calesita, tranquila(chicos)).
atraccion(barcoPirata, intensa(14)).
atraccion(tazasChinas, intensa(6)).
atraccion(simulador3D, intensa(2)).
atraccion(abismoMortal, montanaRusa(3, 134)).
atraccion(paseoPorElBosque, montanaRusa(0, 45)).
atraccion(torpedoSalpicon, acuatica).
atraccion(mudaDeRopa, acuatica).

visitante(eusebio, 80, 3000, 50, 0).
visitante(carmela, 80, 0, 0, 25).
visitante(thom, 52, 6000, 30, 20).
visitante(jonny, 60, 300, 60, 0).
visitante(kidA, 8, 0, 40, 67).

grupo(viejitos, [eusebio, carmela]).
grupo(radiohead, [thom, jonny, kidA]).

% Punto 2

vieneEnGrupo(Persona):-
    grupo(_, Integrantes),
    member(Persona, Integrantes).

sumaHambreAburrimiento(Persona, Total):-
    visitante(Persona,_,_, Hambre, Aburrimiento),
    Total is Hambre + Aburrimiento.

minimoParaEstarMejor(Persona, 1):-
    vieneEnGrupo(Persona).

minimoParaEstarMejor(Persona, 0):-
    visitante(Persona,_,_,_,_),
    not(vieneEnGrupo(Persona)).

estado(Persona, felicidadPlena):-
    sumaHambreAburrimiento(Persona, 0),
    vieneEnGrupo(Persona).

estado(Persona, podriaEstarMejor):-
    sumaHambreAburrimiento(Persona, Total),
    minimoParaEstarMejor(Persona, Minimo),
    between(Minimo, 50, Total).

estado(Persona, necesitaEntretenerse):-
    sumaHambreAburrimiento(Persona, Total),
    between(51, 99, Total).

estado(Persona, seQuiereIrACasa):-
    sumaHambreAburrimiento(Persona, Total),
    Total >= 100.

% Punto 3

esChico(Persona):-
    visitante(Persona, Edad,_,_,_),
    Edad < 13.

puedeComprar(Persona, Comida):-
    visitante(Persona,_, Dinero,_,_),
    comida(Comida, Costo),
    Dinero >= Costo.

satisface(Persona, hamburguesa):-
    visitante(Persona,_,_,Hambre,_),
    Hambre < 50.

satisface(Persona, pancho):-
    esChico(Persona).

satisface(_, lomito).

satisface(Persona, caramelos):-
    visitante(Persona,_,_,_,_),
    forall((comida(Comida,_), Comida \= caramelos), not(puedeComprar(Persona, Comida))).

quedanSatisfechos([Persona], Comida):-
    puedeComprar(Persona, Comida),
    satisface(Persona, Comida).

quedanSatisfechos([Persona|Personas], Comida):-
    quedanSatisfechos([Persona], Comida),
    quedanSatisfechos(Personas, Comida).

grupoQuedaSatisfecho(Grupo, Comida):-
    grupo(Grupo, Integrantes),
    quedanSatisfechos(Integrantes, Comida).

% Punto 4

esAdulto(Persona):-
    visitante(Persona,_,_,_,_),
    not(esChico(Persona)).

masPeligrosa(Atraccion):-
    atraccion(Atraccion, montanaRusa(Giros,_)),
    forall(atraccion(Otra, montanaRusa(OtrosGiros,_)), Giros >= OtrosGiros).

peligrosaPara(Atraccion, Persona):-
    esAdulto(Persona),
    masPeligrosa(Atraccion),
    not(estado(Persona, necesitaEntretenerse)).

peligrosaPara(Atraccion, Persona):-
    esChico(Persona),
    atraccion(Atraccion, montanaRusa(_, Duracion)),
    Duracion > 60.

loHaceVomitar(Persona, Atraccion):-
    atraccion(Atraccion, intensa(Coeficiente)),
    Coeficiente > 10.

loHaceVomitar(Persona, Atraccion):-
    peligrosaPara(Atraccion, Persona).

loHaceVomitar(Persona, tobogan).

lluviaDeHamburguesas(Persona, Atraccion):-
    puedeComprar(Persona, hamburguesa),
    loHaceVomitar(Persona, Atraccion).

% Punto 5

enElMismoGrupo(Persona1, Persona2):-
    grupo(_, Integrantes),
    member(Persona1, Integrantes),
    member(Persona2, Integrantes).

vieneConChicos(Persona):-
    visitante(Persona,_,_,_,_),
    vieneEnGrupo(Persona),
    findall(Chico, (enElMismoGrupo(Persona, Chico), esChico(Chico)), Chicos),
    length(Chicos, Cantidad),
    Cantidad > 0.

aptoParaEdad(Atraccion, Persona):-
    visitante(Persona,_,_,_,_),
    atraccion(Atraccion, tranquila(todos)).

aptoParaEdad(Atraccion, Persona):-
    atraccion(Atraccion, tranquila(chicos)),
    esChico(Persona).

aptoParaEdad(Atraccion, Persona):-
    atraccion(Atraccion, tranquila(chicos)),
    vieneConChicos(Persona).

opcionDisponible(Opcion, Persona,_):-
    puesto(Opcion, Comida),
    puedeComprar(Persona, Comida).

opcionDisponible(Opcion, Persona,_):-
    atraccion(Opcion, tranquila(_)),
    aptoParaEdad(Opcion, Persona).

opcionDisponible(Opcion, Persona,_):-
    atraccion(Opcion, intensa(_)),
    visitante(Persona,_,_,_,_).

opcionDisponible(Opcion, Persona,_):-
    atraccion(Opcion, montanaRusa(_,_)),
    visitante(Persona,_,_,_,_),
    not(peligrosaPara(Opcion, Persona)).

opcionDisponible(Opcion, Persona, Mes):-
    atraccion(Opcion, acuatica),
    visitante(Persona,_,_,_,_),
    member(Mes, [septiembre, octubre, noviembre, diciembre, enero, febrero, marzo]).
