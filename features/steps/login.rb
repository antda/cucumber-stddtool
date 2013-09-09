Givet(/^är utloggad$/) do
	raise "mohahaha exception"
	if(page.has_css?('#navBtnLogout'))
		find('#navBtnLogout').click;
	end
end

Givet(/^att jag är på förstasidan$/) do
visit "http://194.218.9.52:4000/"
end

När(/^jag loggar in som vanlig användare$/) do
find('#navBtnLogin').click
fill_in('login-email', :with => 'anton.danielsson@learningwell.se')
fill_in('login-password', :with => 'kokos')
click_button('login-button')  
end

Så(/^ska jag bli inloggad$/) do
  pending # express the regexp above with the code you wish you had
end

När(/^jag loggar in med fel uppgifter$/) do
  pending # express the regexp above with the code you wish you had
end

Så(/^vill jag inte bli inloggad$/) do
  pending # express the regexp above with the code you wish you had
end

När(/^jag loggar in som administratör$/) do
  pending # express the regexp above with the code you wish you had
end

Så(/^ska jag komma åt adminsidan$/) do
  pending # express the regexp above with the code you wish you had
end

Så(/^ska jag inte komma åt adminsidan$/) do
  pending # express the regexp above with the code you wish you had
end
