%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Languedoc Tree Representation %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%
% Static namespace declarations 
%

:- multifile sxmlns/2.

sxmlns(btf,'http://planet-sl.org/btf').


%
% Parse a root
%

rootToBtf(SG,E,n(P,T))
 :-
    require(
      (
        SG = (S,G,_),
        G = g(_,Ps),
        attribute(targetNamespace,S,Tns),
        E = element(QN,_,_),
        QN = Tns:N,
        children(name(xsd:element),S,EDs),
        member(ED,EDs),
        attribute(name,ED,N),
        splitN(Ps,N,[P],_,_),
        P = p(_,_,X)
      ),
      'No root determined,',
      []),
    eToBtf(SG,QN,X,E,T),
    !.


%
% Parse an entire element
%

eToBtf(SG,N1,X1,E,T3)
 :-
    (
      attribute(xsi:type,E,V) -> 
          (
            require(
              X1 = n(N2),
              'Element ~q with xsi:type=~q is of non-nominal type ~q.',
              [N1,V,X1]),
            SG = (_,G,_),
            G = g(_,Ps),
            splitN1(Ps,N2,P,_,_),
            P = p(_,_,X2),
            (
              X2 = ';'(Xs) ->
                  true
                ; [X2] = Xs
            ),
            Y = n(V),
            require(
              member(Y,Xs),
              'Choice ~q must cover xsi:type=~q.',
              [X2,V]),
            (
              X2 = ';'(Xs) ->
                  T2 = ';'(Y,T1) 
                ; T2 = T1
            ),
            T3 = n(P,T2)
          )
        ;
          (
            Y = X1,
            T3 = T1
          )
    ),
    E = element(_,_,NL1),
    require(
      xToBtf(SG,Y,NL1,NL2,T1),
      'Cannot parse element ~q according to ~q.',
      [N1,Y]),
    require(
      \+ nextElement(NL2,_,_),
      'Element ~q parsed incompletely as ~q according to ~q.',
      [N1,T1,Y]).


%
% Parse nodes according to an expression
%

xToBtf(_,true,NL,NL,true)
 :-
    !.

xToBtf(SG,n(N),NL1,NL2,n(P,T))
 :-
    findGlobal(SG,N,element,_),
    !,
    SG = (S,G,_),
    attribute(targetNamespace,S,Tns),
    nextElement(NL1,E,NL2),
    E = element(QN,_,_),
    QN = Tns:N,
    G = g(_,Ps),
    splitN(Ps,N,[P],_,_),
    P = p(_,_,X),
    eToBtf(SG,N,X,E,T),
    !.

xToBtf(SG,n(N),NL1,NL2,n(P,T))
 :-
    findGlobal(SG,N,group,_),
    !,
    SG = (_,G,_),
    G = g(_,Ps),
    splitN(Ps,N,[P],_,_),
    P = p(_,_,X),
    xToBtf(SG,X,NL1,NL2,T),
    !.

xToBtf(SG,n(N),NL1,NL2,n(P,T))
 :-
    findGlobal(SG,N,complexType,_),
    !,
    SG = (_,G,_),
    G = g(_,Ps),
    splitN1(Ps,N,P,_,_),
    P = p(_,_,X),
    xToBtf(SG,X,NL1,NL2,T),
    !.

xToBtf(SG,n(N1),NL,[],T)
 :-
    findGlobal(SG,N1,simpleType,_),
    !,
    SG = (_,G,_),
    G = g(_,Ps),
    splitN1(Ps,N1,P,_,_),
    P = p(_,_,X1),
    ( 
      % Enumeration type
      ( X1 = ';'(Xs); X1 = s(_,_), Xs = [X1] ),
      NL = [V],
      X2 = s(V,true),
      member(X2,Xs),
      T = n(P,';'(X2,X2))
    ;
      % Predefined simple type
      X1 = n(QN),
      simpleXsdType(SG,QN,NL,T)
    ),
    !.

xToBtf(_,v(string),NL,[],v(string(V)))
 :-
     testSimpleType(string,NL,V).

xToBtf(_,v(int),NL,[],v(int(V3)))
 :-
     testSimpleType(int,NL,V1),
     atom_chars(V1,V2), 
     number_chars(V3,V2).

xToBtf(SG,n(QN),NL,[],T)
 :-
    simpleXsdType(SG,QN,NL,T).

xToBtf(SG,n(QN),NL1,NL2,T)
 :-
    qname(QN,Pfx,N),   
    SG = (S,_,SGs),
    dxmlns(S,Pfx,Ns),
    member(SG1,SGs),
    SG1 = (S1,_),
    attribute(targetNamespace,S1,Ns),
    xToBtf(SG1,n(N),NL1,NL2,T),
    !.

xToBtf(SG,s(Sel,X),NL1,NL2,s(Sel,T))
 :-
    !,
    nextElement(NL1,E,NL2),
    E = element(N,_,_),
    SG = (S,_,_),
    attribute(elementFormDefault,S,unqualified,EFD),
    once(( 
        (
          EFD = unqualified,
          N == Sel
        )
      ;
        ( 
          EFD = qualified,
          attribute(targetNamespace,S,Tns),
          N = Tns:Sel
        ) 
    )),
    eToBtf(SG,Sel,X,E,T),
    !.

xToBtf(SG,','(Xs),Es1,Es2,','(Ts))
 :-
    !,
    accum(xToBtf(SG),Xs,Es1,Es2,Ts),
    !.

xToBtf(SG,';'(Xs),Es1,Es2,';'(X,T))
 :-
    !,
    member(X,Xs),
    xToBtf(SG,X,Es1,Es2,T),
    !.

xToBtf(SG,'*'(X),Es1,Es2,'*'(Ts))
 :-
    !,
    manyToBtf(SG,X,Es1,Es2,Ts),
    !.

xToBtf(SG,'+'(X),Es1,Es2,'+'(Ts))
 :-
    !,
    many1ToBtf(SG,X,Es1,Es2,Ts),
    !.

xToBtf(SG,'?'(X),Es1,Es2,'?'(Ts))
 :-
    !,
    optionalToBtf(SG,X,Es1,Es2,Ts),
    !.


%
% Find a global by name and category
% 

findGlobal(SG,N,C,Gl)
 :-
    uqname(N),
    SG = (S,_,_),
    children(name(xsd:C),S,Gls),
    member(Gl,Gls),
    attribute(name,Gl,N),
    !.


%
% Parse according to occurrence constraints
%

many1ToBtf(SG,X,Es1,Es3,[T|Ts])
 :-
    xToBtf(SG,X,Es1,Es2,T),
    !,
    manyToBtf(SG,X,Es2,Es3,Ts),
    !.

manyToBtf(SG,X,Es1,Es3,[T|Ts])
 :-
    xToBtf(SG,X,Es1,Es2,T),
    !,
    manyToBtf(SG,X,Es2,Es3,Ts),
    !.

manyToBtf(_,_,Es,Es,[])
 :-
    !.

optionalToBtf(SG,X,Es1,Es2,[T])
 :-
    xToBtf(SG,X,Es1,Es2,T),
    !.

optionalToBtf(_,_,Es,Es,[])
 :-
    !.


%
% Parse according to a simple XSD type
%

simpleXsdType(SG,QN,NL,t(V))
 :-
    qname(QN,Pfx,N),
    SG = (S,_,_),
    dxmlns(S,Pfx,Ns),
    sxmlns(xsd,Ns),
    require(
      simpleXsdType(N),
      'Cannot handle simple XSD type ~q.',
      [QN]),
    testSimpleType(N,NL,V).

testSimpleType(N,NL,V)
 :-
    require(
      \+ nextElement(NL,_,_),
      'Simple type ~q expected; elements found.',
      [N]),
    require(
      ( [V] = NL ),
      'Simple type expected; list found.',
      []).

simpleXsdType(int).
simpleXsdType(string).

