local MogIt,mog = ...;
local L = mog.L;

mog.url = {};

function mog:AddURL(name,tbl)
	mog.url[name] = tbl;
end

function mog:ShowURL(id,sub,url,force)
	if not id then return end;
	url = url or mog.db.profile.url;
	sub = sub or "item";
	if not (force or (mog.url[url] and mog.url[url][sub])) then
		url = "Wowhead";
	end
	if mog.url[url] and mog.url[url][sub] then
		local text;
		if type(mog.url[url][sub]) == "function" then
			text = mog.url[url][sub](id);
		else
			text = mog.url[url][sub]:format(id);
		end
		if text then
			StaticPopup_Show("MOGIT_URL",mog.url[url].fav and "\124T"..mog.url[url].fav..":18:18\124t " or "",url,text);
			return true;
		end
	end
end

StaticPopupDialogs["MOGIT_URL"] = {
	text = "%s%s "..L["URL"],
	button1 = CLOSE,
	hasEditBox = 1,
	maxLetters = 512,
	editBoxWidth = 260,
	OnShow = function(self,url)
		self.editBox:SetText(url);
		self.editBox:SetFocus();
		self.editBox:HighlightText();
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

mog:AddURL("Battle.net",{
	fav = "Interface\\AddOns\\MogIt\\Images\\fav_wow",
	item = L["http://eu.battle.net/wow/en/"].."item/%d",
});

mog:AddURL("Wowhead",{
	fav = "Interface\\AddOns\\MogIt\\Images\\fav_wh",
	item = L["http://www.wowhead.com/"].."item=%d",
	set = L["http://www.wowhead.com/"].."itemset=%d",
	npc = L["http://www.wowhead.com/"].."npc=%d",
	spell = L["http://www.wowhead.com/"].."spell=%d",
	compare = function(tbl)
		local str;
		for k,v in pairs(tbl) do
			if str then
				str = str..":"..v;
			else
				str = L["http://www.wowhead.com/"].."compare?items="..v;
			end
		end
		return str;
	end,
});

mog:AddURL("MMO-Champion",{
	fav = "Interface\\AddOns\\MogIt\\Images\\fav_mmo",
	item = "http://db.mmo-champion.com/i/%d/",
	set = "http://db.mmo-champion.com/is/%d/",
	npc = "http://db.mmo-champion.com/c/%d/",
	spell = "http://db.mmo-champion.com/s/%d/",
});

mog:AddURL("WOWDB",{
	--fav = "Interface\\AddOns\\MogIt\\Images\\",
	item = "http://www.wowdb.com/items/%d",
	npc = "http://www.wowdb.com/npcs/%d",
	spell = "http://www.wowdb.com/spells/%d",
});

mog:AddURL("Wowpedia",{
	fav = "Interface\\AddOns\\MogIt\\Images\\fav_wp",
	item = "http://www.wowpedia.org/index.php?search=\"{{elinks-item|%d}}\"",
	set = "http://www.wowpedia.org/index.php?search=\"{{elinks-set|%d}}\"",
	npc = "http://www.wowpedia.org/index.php?search=\"{{elinks-NPC|%d}}\"",
	spell = "http://www.wowpedia.org/index.php?search=\"{{elinks-spell|%d}}\"",
});

mog:AddURL("Thottbot",{
	fav = "Interface\\AddOns\\MogIt\\Images\\fav_tb",
	item = "http://thottbot.com/item=%d",
	set = "http://thottbot.com/itemset=%d",
	npc = "http://thottbot.com/npc=%d",
	spell = "http://thottbot.com/spell=%d",
});

mog:AddURL("Buffed.de",{
	fav = "Interface\\AddOns\\MogIt\\Images\\fav_buff",
	item = "http://wowdata.buffed.de/?i=%d",
	set = "http://wowdata.buffed.de/?set=%d",
	npc = "http://wowdata.buffed.de/?n=%d",
	spell = "http://wowdata.buffed.de/?s=%d",
	compare = function(tbl)
		local str;
		for k,v in pairs(tbl) do
			if str then
				str = str..v..";";
			else
				str = "http://wowdata.buffed.de/itemcompare#"..v..";";
			end
		end
		return str;
	end,
});

mog:AddURL("JudgeHype",{
	fav = "Interface\\AddOns\\MogIt\\Images\\fav_jh",
	item = "http://worldofwarcraft.judgehype.com/?page=objet&w=%d",
	npc = "http://worldofwarcraft.judgehype.com/index.php?page=pnj&w=%d",
	spell = "http://worldofwarcraft.judgehype.com/index.php?page=spell&w=%d",
});