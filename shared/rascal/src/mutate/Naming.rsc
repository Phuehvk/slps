@contributor{Vadim Zaytsev - vadim@grammarware.net - SWAT, CWI}
@wiki{RenameAllN, RenameAllS}
module mutate::Naming

import lib::Rascalware;
import syntax::BGF;
import analyse::Metrics;
import String;
import List;

alias NamingConvention = tuple[Capitalisation cap, str sep];

data Capitalisation
	= uppercase() // UPPERCASE
	| lowercase() // lowercase
	| mixedcase() // mixedCase
	| camelcase() // CamelCase
	;

bool isWordUpper(str w) = w == toUpperCase(w);
bool isWordLower(str w) = w == toLowerCase(w);
bool isWordCapital(str w) = isWordUpper(charAt(w,0)) && isWordUpper(stringChars(tail(chars(w))));

bool isPhraseUpper(list[str] ws) = (isWordUpper(ws[0]) | it && isWordUpper(w) | str w <- tail(ws));
bool isPhraseLower(list[str] ws) = (isWordLower(ws[0]) | it && isWordLower(w) | str w <- tail(ws));
bool isPhraseMixed(list[str] ws) = (isWordLower(ws[0]) | it && isWordCapital(w) | str w <- tail(ws));
bool isPhraseCamel(list[str] ws) = (isWordCapital(ws[0]) | it && isWordCapital(w) | str w <- tail(ws));

bool doesPhraseConform(list[str] ws, Capitalisation::uppercase()) = isPhraseUpper(ws);
bool doesPhraseConform(list[str] ws, Capitalisation::lowercase()) = isPhraseLower(ws);
bool doesPhraseConform(list[str] ws, Capitalisation::mixedcase()) = isPhraseMixed(ws);
bool doesPhraseConform(list[str] ws, Capitalisation::camelcase()) = isPhraseCamel(ws);

bool doesNameConform(str name, NamingConvention ns)
	= doesPhraseConform(name2phrase(name,ns.sep,ns.cap), ns.cap);

list[str] name2phrase(str name, NamingConvention ns) = name2phrase(name, ns.sep, ns.cap);
list[str] name2phrase(str name, "", Capitalisation cap) = name2phrase(name, cap);
default list[str] name2phrase(str name, str sep, Capitalisation _) = split(sep,name); 
list[str] name2phrase(str name, mixedcase()) = splitAtCapital(name);
list[str] name2phrase(str name, camelcase()) = splitAtCapital(name);
default list[str] name2phrase(str name, Capitalisation cap) = [name];

list[str] splitAtCapital(str name)
{
	list[list[int]] res = [[charAt(name,0)]];
	int cx = 0;
	for (c <- tail(chars(name)))
		if (65 <= c && c <= 90)
			{res += [[c]]; cx+=1;}
		else
			res[cx] += [c];
	return [stringChars(c) | c <- res];
}

test bool t1() = splitAtCapital("splitAtCapital") == ["split", "At", "Capital"];
test bool t2() = doesNameConform("compilation-unit", <lowercase(),"-">);

str toCapitalised(str w) = (toUpperCase(stringChar(charAt(w,0))) | it + toLowerCase(stringChar(c)) | c <- tail(chars(w)));

str phrase2name(list[str] ws, NamingConvention nc) = phrase2name(ws, nc.sep, nc.cap);
str phrase2name(list[str] ws, str sep, uppercase())
	= (toUpperCase(ws[0]) | it + sep + toUpperCase(w) | w <- tail(ws));
str phrase2name(list[str] ws, str sep, lowercase())
	= (toLowerCase(ws[0]) | it + sep + toLowerCase(w) | w <- tail(ws));
str phrase2name(list[str] ws, str sep, camelcase())
	= (toCapitalised(ws[0]) | it + sep + toCapitalised(w) | w <- tail(ws));
str phrase2name(list[str] ws, str sep, mixedcase())
	= (toLowerCase(ws[0]) | it + sep + toCapitalised(w) | w <- tail(ws));

public BGFGrammar changeConventionN(BGFGrammar g, NamingConvention src, NamingConvention tgt)
{
	XBGFSequence x = [];
	str nn;
	for (n <- allNs(g))
		if (doesNameConform(n,src))
		{
			nn = phrase2name(name2phrase(n,src),tgt);
			if (n != nn)
				x += [renameN(n, nn)];
		}
	return transform(x,g);
}

public BGFGrammar changeConventionS(BGFGrammar g, NamingConvention src, NamingConvention tgt)
{
	// works only on selectors with globally unique names
	XBGFSequence x = [];
	str nn;
	for (n <- allSs(g))
		if (doesNameConform(n,src))
		{
			nn = phrase2name(name2phrase(n,src),tgt);
			if (n != nn)
				x += [renameS(n, nn, globally())];
		}
	return transform(x,g);
}

// predefined changes for nonterminals
public BGFGrammar changeDashedUpper2GluedCamelN(BGFGrammar g)
	= changeConventionN(g, <uppercase(),"-">, <camelcase(),"">);
public BGFGrammar changeDashedLower2GluedCamelN(BGFGrammar g)
	= changeConventionN(g, <lowercase(),"-">, <camelcase(),"">);
public BGFGrammar changeDashedUpper2GluedMixedN(BGFGrammar g)
	= changeConventionN(g, <uppercase(),"-">, <mixedcase(),"">);
public BGFGrammar changeDashedLower2GluedMixedN(BGFGrammar g)
	= changeConventionN(g, <lowercase(),"-">, <mixedcase(),"">);

// predefined changes for selectors
public BGFGrammar changeDashedUpper2GluedCamelS(BGFGrammar g)
	= changeConventionS(g, <uppercase(),"-">, <camelcase(),"">);
public BGFGrammar changeDashedLower2GluedCamelS(BGFGrammar g)
	= changeConventionS(g, <lowercase(),"-">, <camelcase(),"">);
public BGFGrammar changeDashedUpper2GluedMixedS(BGFGrammar g)
	= changeConventionS(g, <uppercase(),"-">, <mixedcase(),"">);
public BGFGrammar changeDashedLower2GluedMixedS(BGFGrammar g)
	= changeConventionS(g, <lowercase(),"-">, <mixedcase(),"">);
