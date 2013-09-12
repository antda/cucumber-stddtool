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


När(/^jag går till youtube$/) do
  visit "http://youtube.com/"
end

När(/^söker på "(.*?)"$/) do |arg1|
  fill_in('masthead-search-term', :with => arg1)
  click_button('search-btn');
end

Så(/^ska jag hitta videon "(.*?)"$/) do |arg1|
  page.should have_content arg1
end

