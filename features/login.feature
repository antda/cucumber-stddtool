# language: sv	
@login
Egenskap: Logga in
	För att kunna skapa annonser
	Som en användare
	Vill jag kunna logga in på hemsidan

Bakgrund: Jag befinner mig på förstasidan
	Givet att jag är på förstasidan

Scenario: En användare ska kunna logga in med korrekta uppgifter
	När jag loggar in som vanlig användare
	Så ska jag bli inloggad

Scenario: En användare ska inte kunna logga in med fel uppgifter
	När jag loggar in med fel uppgifter
	Så vill jag inte bli inloggad

Scenario: En administratör ska kunna se admin-sidan
	När jag loggar in som administratör
	Så ska jag komma åt adminsidan

Scenario: En vanlig användare ska inte kunna se admin-sidan
	När jag loggar in som vanlig användare
	Så ska jag inte komma åt adminsidan
