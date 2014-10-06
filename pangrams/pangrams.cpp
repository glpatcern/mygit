// pangrams.cpp  -  v. articoli su Lee Sallows in "Divertirsi con il calcolatore"
// prima versione (Pascal): Ago 1996
// versione riscritta in C: Nov 2001
// ripresa per Linux: Ago 2005
#include <iostream.h>
#include <stdlib.h>
#include <string.h>

void exit(int);

// i primi 40 numerali
char nums[41][15] = {"(zero)", "una", "due", "tre", "quattro", "cinque", "sei", "sette",
   "otto", "nove", "dieci", "undici", "dodici", "tredici", "quattordici", "quindici",
   "sedici", "diciassette", "diciotto", "diciannove", "venti", "ventuno", "ventidue",
   "ventitre", "ventiquattro", "venticinque", "ventisei", "ventisette", "ventotto",
   "ventinove", "trenta", "trentuno", "trentadue", "trentatre", "trentaquattro",
   "trentacinque", "trentasei", "trentasette", "trentotto", "trentanove", "quaranta"};

// schema di pangramma
char frase[] = "questo pangramma generato al calcolatore, contenente ? a, una b, ? c, ? d, ? e, una f, cinque g, una h, ? i, sei l, tre m, ? n, ? o, sei p, ? q, ? r, ? s, ? t, ? u, ? v, una z, ventitre virgole e un punto, e stato trovato da giuseppe lo presti.";

// valori iniziali e finali di tutti i contatori
const int ini[13] = {15,  7,  7, 26, 14, 20, 19,  6, 11,  9, 30, 16,  6};
const int fin[13] = {24, 12, 12, 35, 22, 25, 27, 10, 16, 14, 40, 20, 10};

// lettere "variabili" del pangramma (sono 13):
char lVar[13] = {'a','c','d','e','i','n','o','q','r','s','t','u','v'};
char ilVar['z'];     // array per il mapping inverso di lVar - cfr. contaLett()
#define corn 13
#define tot 14

/************************************************************************************/

int pg[15][13];     // pangramma corrente: valori per le lettere + cornice + totali
int occ[40][13];    // matrice delle occorrenze: ogni riga i contiene le occorrenze delle lettere del numerale di i+1
int ct[13];         // contatori = combinazione corrente
double spazio;      // dimensione spazio di ricerca
int i,j, prove, proveMld;
bool fine;


void contaLett(char* s, int* r) {     // conta le occorrenze delle lettere in s e le memorizza in r
	for(int i = 0; i < 13; i++)
		r[i] = 0;
	for(unsigned int i = 0; i < strlen(s); i++)
		r[ilVar[s[i]]]++;          // ilVar[s[i]] = indice dell'i-esimo carattere in s
	/*
	for(i = 0; i < 13; i++) {
		r[i] = 0;
		p = pos(lVar[i], s);
		while(p > 0) {
			r[i]++;
			s[p] = ' ';
			p = pos(lVar[i], s);
			}
		}
	*/
}

void init() {    // inizializza la riga pg[tot] e la matrice occ
	spazio = 1;
	for(i = 0; i < 13; i++, spazio *= fin[i] - ini[i] + 1);
	cout << "Ricerca pangramma in corso su " << spazio << " possibilita'..." << endl;
	for(i = 0; i <= 'z'; i++) ilVar[i] = -1;
	for(char c = 0; c < 13; c++) ilVar[lVar[c]] = c;
	for(i = 1; i <= 40; i++)
		contaLett(nums[i], occ[i]);
	contaLett(frase, pg[corn]);      // prepara i conteggi per lo scheletro
	// ora aggiusta le maiuscole e l'accentata (non sarebbero state contate)
	frase[0] = 'Q';
	frase[strlen(frase)-38] = 'è';
	frase[strlen(frase)-19] = 'G';
	frase[strlen(frase)-10] = 'L';
	frase[strlen(frase)-7] = 'P';
	prove = 1;
	proveMld = 0;
}

void done() {
	char** lCost = new char*['z'+1];
    lCost['b'] = lCost['f'] = lCost['h'] = lCost['z'] = nums[1];
    lCost['g'] = nums[5];
    lCost['l'] = nums[6];
    lCost['m'] = nums[3];
    lCost['p'] = nums[6];
	cout << "Pangramma trovato! Tentativo n. " << prove << endl << endl;
	frase[53] = '\0';    // così stampa solo la prima parte
	cout << frase;
	for(char l = 'a'; l <= 'z'; l++)
		if(ilVar[l] != -1)
			cout << nums[ct[ilVar[l]]] << " " << l << ", ";
      	else if(l != 'j' && l != 'k' && l != 'w' && l != 'x' && l != 'y')
      		cout << lCost[l] << " " << l << ", ";
	frase[53] = '0';
    char* fr = frase + strlen(frase)-67;        // ora viene la parte finale
    cout << fr << endl;
    cin >> i;
	std::exit(1);
}


void somma() {
	fine = true;
	for(i = 0; i < 13 && fine; i++) {     // per ogni lettera lVar[i]...
		pg[tot][i] = pg[corn][i];
		for(j = 0; j < corn; j++)    // somma i contributi a lVar[i] delle altre lettere ("? c, ...")
			pg[tot][i] += pg[j][i];         // e della frase
		fine &= pg[tot][i] == ct[i];
	}
}

void main() {
 init();
 // iterazione del metodo:
 for(ct[12] = ini[12]; ct[12] <= fin[12]; ct[12]++) {           // v
 	for(int k = 0; k < 15; k++) pg[12][k] = occ[ct[12]][k];
 for(ct[7] = ini[7]; ct[7] <= fin[7]; ct[7]++) {                // q
 	for(int k = 0; k < 15; k++) pg[7][k] = occ[ct[7]][k];
 for(ct[11] = ini[11]; ct[11] <= fin[11]; ct[11]++) {           // u
 	for(int k = 0; k < 15; k++) pg[11][k] = occ[ct[11]][k];
 for(ct[2] = ini[2]; ct[2] <= fin[2]; ct[2]++) {                // d
 	for(int k = 0; k < 15; k++) pg[2][k] = occ[ct[2]][k];
 for(ct[1] = ini[1]; ct[1] <= fin[1]; ct[1]++) {                // c
 	for(int k = 0; k < 15; k++) pg[1][k] = occ[ct[1]][k];
 for(ct[8] = ini[8]; ct[8] <= fin[8]; ct[8]++) {                // r
 	for(int k = 0; k < 15; k++) pg[8][k] = occ[ct[8]][k];
 for(ct[9] = ini[9]; ct[9] <= fin[9]; ct[9]++) {		// s
 	for(int k = 0; k < 15; k++) pg[9][k] = occ[ct[9]][k];
 for(ct[6] = ini[6]; ct[6] <= fin[6]; ct[6]++) {                // o
 	for(int k = 0; k < 15; k++) pg[6][k] = occ[ct[6]][k];
 for(ct[5] = ini[5]; ct[5] <= fin[5]; ct[5]++) {                // n
 	for(int k = 0; k < 15; k++) pg[5][k] = occ[ct[5]][k];
 for(ct[4] = ini[4]; ct[4] <= fin[4]; ct[4]++) {                // i
 	for(int k = 0; k < 15; k++) pg[4][k] = occ[ct[4]][k];
 for(ct[0] = ini[0]; ct[0] <= fin[0]; ct[0]++) {                // a
 	for(int k = 0; k < 15; k++) pg[0][k] = occ[ct[0]][k];
 for(ct[10] = ini[10]; ct[10] <= fin[10]; ct[10]++) {           // t
 	for(int k = 0; k < 15; k++) pg[10][k] = occ[ct[10]][k];
 for(ct[3] = ini[3]; ct[3] <= fin[3]; ct[3]++) {                // e
 	for(int k = 0; k < 15; k++) pg[3][k] = occ[ct[3]][k];

	somma();
 	if(fine) done();
 	if(prove % 1000000000 == 0) {
      proveMld++;
      prove = 0;
		cout << "Prova n. " << proveMld << " mld (" << proveMld*1E+11/spazio << " %)" << endl;
      }
 	prove++;

 }}}}}}}}}}}}}

 cout << "Pangramma non trovato" << endl;
}

