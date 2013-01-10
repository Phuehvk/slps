@contributor{Vadim Zaytsev - vadim@grammarware.net - SWAT, CWI}
module transform::NegotiatedXBGF

import lib::Rascalware;
import IO;
import syntax::BGF;
import syntax::XBGF;
import normal::BGF;
import transform::library::Util;
import transform::XBGF;
import transform::Results;

public tuple[BGFGrammar,XBGFOutcome,set[XBGFCommand]] attemptTransform(XBGFCommand xbgf, BGFGrammar g)
{
	XBGFResult res = transform::XBGF::vtransform(xbgf, g);
	//iprintln(res.r);
	return <g,res.r,negotiate(res.g,xbgf,res.r)>;	
}

public BGFGrammar transformAnyway(XBGFSequence xbgf, BGFGrammar g)
{
	for (XBGFCommand step <- xbgf)
		g = keepTrying(step,g);
	return g;
}

BGFGrammar keepTrying(XBGFCommand step, BGFGrammar g)
{
	<g,out,adv> = attemptTransform(step,g);
	if (ok() := out)
		return normalise(g2);
	else
	{
		report(out);
		if (len(adv)>0)
			return keepTrying(getOneFrom(adv),g);
		else
			thw(out);
	}
}

	//= <g,negotiate(transform::XBGF::transform(xbgf, g))>;
//{
//	XBGFResult res = transform::XBGF::transform(xbgf, g);
//	switch(res.r)
//	{
//		case ok(): return <g,{}>;
//		default: return <g,negotiate(res.r, res.g)>;
//		//default: report(res.r);
//	}
//	return <g,{}>;
//}
//
//tuple[BGFGrammar,set[XBGFCommand]] negotiate(XBGFResult r, BGFGrammar g) = <

set[XBGFCommand] negotiate(BGFGrammar g, XBGFCommand _, ok()) = {};
set[XBGFCommand] negotiate(BGFGrammar g, renameN(str x, str y), problemStr("Nonterminal must not be fresh", x))
	= {renameN(n,y) | str n <- adviseUsedNonterminal(x,allNs(g.prods))};
default set[XBGFCommand] negotiate(BGFGrammar _, XBGFCommand _, XBGFOutcome _) = {};

//data Problem
//	= noproblem()
//	| error(str m);
//
//data Advice
//	= noadvice()
//	| setadvice(str s, set[str] a);


//tuple[Problem,Advice,BGFGrammar] runAbridge(BGFProduction prod, grammar(rs, ps))
//{
//	if (production(_,x,nonterminal(x)) !:= prod)
//		return
//		<
//			error("Production <prod> cannot be abridged."),
//			adviseDetouredProd(prod,ps), // NOT IMPLEMENTED YET
//			grammar(rs,ps)
//		>;
//	if (!inProds(prod,ps))
//		return
//		<
//			error("Production <prod> not found."),
//			setadvice("Consider the nonterminal <prod.lhs> already abridged.",[]),
//			grammar(rs,ps)
//		>;
//	return <noproblem(),noadvice(),grammar(rs, ps - prod)>;
//}
//
//
//tuple[Problem,Advice,BGFGrammar] runRenameN(str x, str y, grammar(rs, ps))
//{
//	ns = allNs(ps);
//	if (x notin ns)
//		return
//		<
//			error("Source name <x> for renaming must not be fresh."),
//			adviseUsedNonterminal(x,allNs(ps)),
//			grammar(rs, ps)
//		>;
//	if (y in ns)
//		return
//		<
//			error("Target name <y> for renaming must be fresh."),
//			adviseFreshNonterminal(y,allNs(ps)),
//			grammar(rs, ps)
//		>;
//	return <noproblem(),noadvice(),transform::library::Core::performRenameN(x,y,grammar(rs,ps))>;
//}

set[str] adviseUsedNonterminal(str x, set[str] nts)
{
	int minl = 9000;
	str mins = "";
	//good = {z | z <- nts, levenshtein(z,x) == min([levenshtein(s,x) | s <- nts])};
	return {z | z <- nts, levenshtein(z,x) == min([levenshtein(s,x) | s <- nts])};
	//if (isEmpty(good))
	//	return noadvice();
	//else
	//	return setadvice("Did you mean",good);
}

//Advice adviseFreshNonterminal(str x, set[str] nts)
//{
//	list[str] low = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y"];
//	list[str] upp = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y"];
//	set[str] adv = {};
//	int cx = 1;
//	str s = x;
//	// expr -> expr1
//	while ("<x><cx>" in nts) cx+=1;
//	adv += "<x><cx>";
//	cx = 0;
//	// expr -> expr_
//	while (s in nts) s += "_"; 
//	adv += s;
//	// expr -> shjk
//	s = "";
//	for (c <- [stringChar(charAt(x,i)) | i <- [0..len(x)-1]])
//		if (c in low)
//			s += low[arbInt(len(low))];
//		elseif (c in upp)
//			s += upp[arbInt(len(upp))];
//		else
//			s += stringChar(c);
//	adv += s;
//	return setadvice("Did you mean",adv);
//}