# language: sv	

Egenskap: Skapa annons
	För att kunna informera andra om objektet jag vill bli av med
	Som en användare
	Vill jag kunna skapa annonser på sidan

Bakgrund: Jag befinner mig på förstasidan
	Givet att jag är på förstasidan
	Och är utloggad

Scenario: En användare skapar en annons
	När jag loggar in som vanlig användare
	Och lägger upp en ny annons
	Så ska annonsen skapas

Scenario: En användare skapar en annons utan titel
	När jag loggar in som vanlig användare
	Och lägger upp en ny annons utan titel
	Så vill jag få ett felmeddelande

Scenario: En användare skapar en intern annons
	När jag loggar in som vanlig användare
	Och lägger upp en intern annons
	Så ska annonsen endast visas internt

Scenario: En användare skapar en annons och anger priset i bokstäver
	När jag loggar in som vanlig användare
	Och lägger upp en annons med priset i bokstäver
	Så vill jag få ett felmeddelande
