# Proof checker for natural deduction

## Natural deduction for propositional logic
Propositional logic allows us to build up expressions from propositional variables A,B,C,… using propositional connectives like →, ∧, ∨, and ¬. Natural deduction is a formal prove system where every logical reasoning is expressed with inference rules similar to natural reasoning. Proofs are built by putting together smaller proofs, according to the rules.In this system every proof starts with some hypothesis and ends up with some conclusion.

## Rules for propositional logic
Natural deduction rules are divided into two groups: elimination rules and introducing rules. A set of rules should be complete and sound to make it possible to infer any valid conclusion and never infer invalid ones. 

<p align="center">
<img width="543" alt="rules" src="https://user-images.githubusercontent.com/9019397/80528156-c9620c80-8995-11ea-8d55-08ae45b45ee5.png">
  </p>

## Proof notation

Every proof starts with the word **goal**, then there is particular proof's name and the formula we want to prove. Exact proof is placed between two key wrods **proof** and **end.**. Example proof can look like that:

<p>
<img width="563" alt="proof" src="https://user-images.githubusercontent.com/9019397/80528154-c830df80-8995-11ea-9c8b-c4564cb695e6.png">
  </p>

Proof is written in linear notation where the nested proofs are separated with semicolon. Each of them can be either a single formula or a *frame*. A single formula must be possible to infer using reasoning rules and facts that were proven ealier in the proof. 
A frame is written in square braces and it consists a single fomrula — its premise and a proof using that premise. We can consider following example as a part of some bigger proof: **[A: A]**.
It stands for **assume A is true, then A**. We can infer A inside the frame due to its premise. And the conclusion would be **A => A**, which is the only information we can use in the next steps of the proof. We can no longer use previous assumption about **A** thus it was only avaliable inside the frame. 

## Syntax

* Conjunxtion: /\
* Disjunction: \/
* Implication: =>
* Equality: <=>
* Negation: ~
* True: T
* False: F


## Examples

```
goal example_3: p => ~~p	
proof
[p:
  [~p: F];
  ~~p];
p => ~~p;    
end.
```
In the above proof we have a frame with a premise **p** and then in the nested frame **~p** is introduced. Since we have assumptions **p** and **~p** the rule **elimination of negation** allows us to infer **F** and the rule **introducing of negation** leads us to conclusion **~~p**. As the second element of the proof we have the frame's conclusion **p => ~~p** which is what we wanted to prove.


```
goal example_1: p /\ q => q /\ p
proof
[p /\ q:
  q;
  p;
  q /\ p];
p /\ q => q /\ p
end.
```
In the above example we have a proof consisting two elements. The first one is the frame with premise **p /\ q**. Then we have **q** and **p** which are both inferred using the rule **elimination of conjunction**. They are now our local proven facts we can use further. In the next line there is applied rule **introducing of conjunction**, so that we have **q /\ p**. In the second element of the proof we just have the conclusion of the frame.

```
goal example_2: p \/ q => q \/ p
proof
[p \/ q:
  [p: q \/ p];
  p => q \/ p;
  [q: q \/ p];
  q => q \/ p;
  q \/ p];
p \/ q => q \/ p
end.
```
Now we have a little bit more complex proof with some nested frames inside. As in previous example it also consists two elements and first we are going to focus on the frame. It infers the premise **p \/ q** and the first frames's formula is an another frame in which the fact **q \/ p** can be deduced using premise **p** and the rule **introducing of disjunction**. Then we have conclusion of the first nested frame. Next line look similar to the one that was just described with the same rule **introducing of disjunction** used to conclude **q => q \/ p**. Now we have three facts: **p \/ q** from premise, **p => q \/ p** and **q => q \/ p**. Due to the facts and the rule **elimination of conjunction** it is possible to infer **q \/ p**. Thus we evaluated corectness of the frame we have its conclusion **p \/ q => q \/ p**.

## Development

### Requirements (OCaml packages)

* ocamlfind

* menhir

* core

```
ocamlbuild -use-menhir -tag thread -use-ocamlfind -quiet -pkg core main.native
```

## Testing

```
./main.native input_file output_file [option]
```

### Options

* bind - allows to use in further proofs facts proven earlier in the file and axioms

#### Example usage

```
./main.native input_file output_file bind
```
