local MogIt,mog = ...;
local L = mog.L;

local slots = {
	"HeadSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"ShirtSlot",
	"TabardSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
	"RangedSlot",
};

mog.view = CreateFrame("Frame","MogItPreview",UIParent,"ButtonFrameTemplate");
mog.view:SetPoint("CENTER",UIParent,"CENTER");
mog.view:SetSize(369,369);
mog.view:SetToplevel(true);
mog.view:SetClampedToScreen(true);
mog.view:EnableMouse(true);
mog.view:SetMovable(true);
mog.view:SetResizable(true);
mog.view:SetUserPlaced(true);
mog.view:SetScript("OnMouseDown",mog.view.StartMoving);
mog.view:SetScript("OnMouseUp",mog.view.StopMovingOrSizing);
tinsert(UISpecialFrames,"MogItPreview");

MogItPreviewBg:SetVertexColor(0.8,0.3,0.8);
MogItPreviewTitleText:SetText(L["Preview"]);
mog.view.portraitFrame:Hide();
mog.view.topLeftCorner:Show();
mog.view.topBorderBar:SetPoint("TOPLEFT",mog.view.topLeftCorner,"TOPRIGHT",0,0);
mog.view.leftBorderBar:SetPoint("TOPLEFT",mog.view.topLeftCorner,"BOTTOMLEFT",0,0);
mog.view.Inset:SetPoint("TOPLEFT",mog.view,"TOPLEFT",44,-60);
mog.view.Inset:SetPoint("BOTTOMRIGHT",mog.view,"BOTTOMRIGHT",-47,26);

mog.view.resize = CreateFrame("Frame",nil,mog.view);
mog.view.resize:SetSize(16,16);
mog.view.resize:SetPoint("BOTTOMRIGHT",mog.view,"BOTTOMRIGHT",-4,3);
mog.view.resize:EnableMouse(true);
mog.view.resize:SetScript("OnMouseDown",function(self)
	mog.view:SetMinResize(369,369);
	mog.view:SetMaxResize(GetScreenWidth(),GetScreenHeight());
	mog.view:StartSizing();
end);
mog.view.resize:SetScript("OnMouseUp",function(self)
	mog.view:StopMovingOrSizing();
	self:SetScript("OnUpdate",nil);
end);
mog.view.resize:SetScript("OnHide",mog.view.resize:GetScript("OnMouseUp"));
mog.view.resize.texture = mog.view.resize:CreateTexture(nil,"OVERLAY");
mog.view.resize.texture:SetSize(16,16);
mog.view.resize.texture:SetTexture("Interface\\AddOns\\MogIt\\Images\\Resize");
mog.view.resize.texture:SetAllPoints(mog.view.resize);

mog.view.model = CreateFrame("Button",nil,mog.view);
mog.view.model:SetPoint("TOPLEFT",mog.view.Inset,"TOPLEFT",10,-10);
mog.view.model:SetPoint("BOTTOMRIGHT",mog.view.Inset,"BOTTOMRIGHT",-10,10);
mog.view.model:EnableMouseWheel(true);
mog.view.model:SetScript("OnMouseWheel",function(self,v)
	mog.posZ = mog.posZ + ((v > 0 and 0.6) or -0.6);
	mog.updateModels();
end);
mog.view.model:SetScript("OnShow",function(self,...)
	self.model:SetPosition(mog.posZ,mog.posX,mog.posY);
	self.model:Undress();
	mog:DressModel(self.model);
	if self:GetFrameLevel() <= mog.view:GetFrameLevel() then
		self:SetFrameLevel(mog.view:GetFrameLevel()+1);
	end
end);
mog.view.model:SetScript("OnHide",function(self)
	if mog.modelUpdater.model == self then
		self:GetScript("OnDragStop")(self);
	end
	self.model:SetPosition(0,0,0);
end);
mog.view.model:RegisterForDrag("LeftButton","RightButton");
mog.view.model:SetScript("OnDragStart",function(self,btn)
	mog.modelUpdater.btn = btn;
	mog.modelUpdater.model = self;
	mog.modelUpdater.prevx,mog.modelUpdater.prevy = GetCursorPosition();
	mog.modelUpdater:Show();
end);
mog.view.model:SetScript("OnDragStop",function(self,btn)
	mog.modelUpdater:Hide();
	mog.modelUpdater.btn = nil;
	mog.modelUpdater.model = nil;
end);

mog.view.model.model = CreateFrame("DressUpModel",nil,mog.view.model);
mog.view.model.model:SetModelScale(2);
mog.view.model.model:SetPosition(0,0,0);
mog.view.model.model:SetAllPoints(mog.view.model);
mog.view.model.model.button = mog.view.model;
		
mog.view.model.bg = mog.view.model:CreateTexture(nil,"BACKGROUND");
mog.view.model.bg:SetAllPoints(mog.view.model);
mog.view.model.bg:SetTexture(0.3,0.3,0.3,0.2);

mog.view.clear = CreateFrame("Button","MogItFramePreviewClear",mog.view,"UIPanelButtonTemplate2");
mog.view.clear:SetPoint("TOPRIGHT",mog.view,"TOPRIGHT",-10,-30);
mog.view.clear:SetWidth(100);
mog.view.clear:SetText(L["Clear"]);
mog.view.clear:SetScript("OnClick",function(self,btn)
	for k,v in pairs(mog.view.slots) do
		mog.view.delItem(k);
	end
end);

mog.view.link = CreateFrame("Button","MogItFramePreviewLink",mog.view,"MagicButtonTemplate");
mog.view.link:SetPoint("BOTTOMLEFT",mog.view,"BOTTOMLEFT",5,5);
mog.view.link:SetWidth(100);
mog.view.link:SetText(L["Chat Link"]);
mog.view.link:SetScript("OnClick",function(self,btn)
	local tbl = {};
	for k,v in pairs(mog.view.slots) do
		if v.item then
			table.insert(tbl,v.item);
		end
	end
	ChatEdit_InsertLink(mog:SetToLink(tbl));
end);

mog.view.add = CreateFrame("Button","MogItFramePreviewAddItem",mog.view,"MagicButtonTemplate");
mog.view.add:SetPoint("TOPLEFT",mog.view.link,"TOPRIGHT");
mog.view.add:SetWidth(100);
mog.view.add:SetText(L["Add Item"]);
mog.view.add:SetScript("OnClick",function(self,btn)
	StaticPopup_Show("MOGIT_PREVIEW_ADDITEM");
end);

mog.view.import = CreateFrame("Button","MogItFramePreviewImport",mog.view,"MagicButtonTemplate");
mog.view.import:SetPoint("TOPLEFT",mog.view.add,"TOPRIGHT");
mog.view.import:SetWidth(100);
mog.view.import:SetText(L["Import"]);
mog.view.import:SetScript("OnClick",function(self,btn)
	StaticPopup_Show("MOGIT_PREVIEW_IMPORT");
end);

function mog.view.setTexture(slot,texture)
	SetItemButtonTexture(mog.view.slots[slot],texture or select(2,GetInventorySlotInfo(slot)));
end

mog.view.slots = {};
for k,v in ipairs(slots) do
	mog.view.slots[v] = CreateFrame("Button","MogItPreview"..v,mog.view,"ItemButtonTemplate");
	mog.view.slots[v].slot = v;
	if k == 1 then
		mog.view.slots[v]:SetPoint("TOPLEFT",mog.view,"TOPLEFT",5,-60);
	elseif k == 8 then
		mog.view.slots[v]:SetPoint("TOPRIGHT",mog.view,"TOPRIGHT",-7,-60);
	else
		mog.view.slots[v]:SetPoint("TOP",mog.view.slots[slots[k-1]],"BOTTOM",0,-4);
	end
	
	local id,texture = GetInventorySlotInfo(v);
	mog.view.setTexture(v);
	
	mog.view.slots[v]:RegisterForClicks("AnyUp");
	mog.view.slots[v]:SetScript("OnClick",function(self,btn)
		if not self.item then return end;
		if btn == "LeftButton" then
			if IsShiftKeyDown() then
				local _,link = GetItemInfo(self.item);
				if link then
					ChatEdit_InsertLink(link);
				end
			elseif IsControlKeyDown() then
				DressUpItemLink(self.item);
			else
				
			end
		elseif btn == "RightButton" then
			if IsControlKeyDown() then
				mog.view.delItem(self.slot);
				if mog.db.profile.gridDress then
					mog.scroll:update();
				end
			elseif IsShiftKeyDown() then
				mog:ShowURL(self.item);
			else
				
			end
		end
	end);
	--[=[mog.view.slots[k]:SetScript("OnEnter",function(self)
		if self.item then
			--GameTooltip:SetItemByID(self.item);
			mog.itemTooltip(self);
		else
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:SetText(_G[strupper(mog.itemSlots[self.slot])]);
		end
	end);
	mog.view.slots[k]:SetScript("OnLeave",function(self)
		GameTooltip:Hide();
	end);--]=]
end

mog.view.wait = {};
function mog:AddToPreview(item,set)
	if not item then return end;
	local slot,texture = select(9,GetItemInfo(item));
	if not slot then
		mog.view.wait[item] = (mog.view.wait[item] or 0) + 1;
		return;
	end
	if mog.invSlots[slot] then
		if slot == "INVTYPE_2HWEAPON" then
			if select(2,UnitClass("PLAYER")) == "WARRIOR" and (select(5,GetTalentInfo(2,20)) or 0) > 0 then
				slot = "INVTYPE_WEAPON";
			end
		end
		if slot == "INVTYPE_WEAPON" and not mog.view.twohand then
			if mog.view.slots.MainHandSlot.item and ((not mog.view.slots.SecondaryHandSlot.item) or mog.view.slots.MainHandSlot.item == item) then
				slot = "INVTYPE_WEAPONOFFHAND";
			end
		end
		
		if slot == "INVTYPE_2HWEAPON" then
			mog.view.delItem("SecondaryHandSlot");
			mog.view.twohand = true;
		elseif slot == "INVTYPE_WEAPONOFFHAND" then
			if mog.view.twohand then
				mog.view.delItem("MainHandSlot");
			end
			mog.view.twohand = nil;
		elseif slot == "INVTYPE_WEAPON" then
			mog.view.twohand = nil;
		elseif slot == "INVTYPE_WEAPONMAINHAND" then
			mog.view.twohand = nil;
		end
		
		mog.view.slots[mog.invSlots[slot]].item = item;
		-- item history
		mog.view.setTexture(mog.invSlots[slot],texture);
		if mog.view:IsShown() then
			mog.view.model.model:TryOn(item);
		else
			ShowUIPanel(mog.view);
		end
		
		if (not set) and mog.db.profile.gridDress then
			mog.scroll:update();
		end
	end
end

function mog.view.delItem(slot)
	mog.view.slots[slot].item = nil;
	mog.view.setTexture(slot);
	mog.view.model.model:Undress(); -- <--
	mog:DressModel(mog.view.model.model);
	--[=[if GameTooltip:GetOwner() == mog.view.slots[slot] then
		GameTooltip:Hide();
	end--]=]
end

function mog:DressModel(model)
	if mog.db.profile.gridDress or (model == mog.view.model.model) then
		for k,v in pairs(mog.view.slots) do
			if v.item then
				model:TryOn(v.item);
			end
		end
	end
end

hooksecurefunc("HandleModifiedItemClick",function(link)
	if link then
		if (GetMouseButtonClicked() == "RightButton") and IsControlKeyDown() then
			if type(link) == "string" then
				link = tonumber(link:match("item:(%d+)"));
			end
			mog:AddToPreview(link);
		end
	end
end);

local function hookInspectUI()
	for k,v in ipairs(slots) do
		_G["Inspect"..v].slot = v;
		_G["Inspect"..v]:RegisterForClicks("AnyUp");
		_G["Inspect"..v]:HookScript("OnClick",function(self,btn)
			if InspectFrame.unit and self.hasItem then
				if btn == "RightButton" and IsControlKeyDown() then
					mog:AddToPreview(GetInventoryItemID(InspectFrame.unit,GetInventorySlotInfo(self.slot)));
				end
			end
		end);
	end
end
if InspectFrame then
	hookInspectUI();
end

local function hookGuildBankUI()
	for column=1,NUM_GUILDBANK_COLUMNS do
		for row=1,NUM_SLOTS_PER_GUILDBANK_GROUP do
			local old = _G["GuildBankColumn"..column.."Button"..row]:GetScript("OnClick");
			_G["GuildBankColumn"..column.."Button"..row]:SetScript("OnClick",function(self,btn,...)
				if btn == "RightButton" and IsControlKeyDown() then
					local link = GetGuildBankItemLink(GetCurrentGuildBankTab(),self:GetID());
					link = link and link:match("item:(%d+)");
					mog:AddToPreview(tonumber(link));
				else
					return old(self,btn,...);
				end
			end);
		end
	end
end
if GuildBankFrame then
	hookGuildBankUI();
end

local function hookALB()
	local old = AphesLootBrowser.ItemClick;
	function AphesLootBrowser.ItemClick(self,item,btn,...)
		if type(item) == "number" and btn == "RightButton" and IsControlKeyDown() then
			mog:AddToPreview(item);
		else
			return old(self,item,btn,...);
		end
	end
end
if AphesLootBrowser then
	hookALB();
end

local old_SetItemRef = SetItemRef;
function SetItemRef(link,text,btn,...)
	local id = tonumber(link:match("^item:(%d+)"));
	if id and btn == "RightButton" and IsControlKeyDown() then
		mog:AddToPreview(id);
	else
		return old_SetItemRef(link,text,btn,...);
	end
end

mog.view:SetScript("OnEvent",function(self,event,arg1,...)
	if event == "ADDON_LOADED" then
		if arg1 == "Blizzard_InspectUI" then
			hookInspectUI();
		elseif arg1 == "Blizzard_GuildBankUI" then
			hookGuildBankUI();
		elseif arg1 == "AphesLootBrowser" then
			hookALB();
		end
	elseif event == "GET_ITEM_INFO_RECEIVED" then
		for k,v in pairs(mog.view.wait) do
			if select(9,GetItemInfo(k)) then
				for i=1,v do
					mog:AddToPreview(k);
				end
				mog.view.wait[k] = nil;
			end
		end
	end
end);
mog.view:RegisterEvent("ADDON_LOADED");
mog.view:RegisterEvent("GET_ITEM_INFO_RECEIVED");

StaticPopupDialogs["MOGIT_PREVIEW_ADDITEM"] = {
	text = L["Type the item ID or url in the text box below"],
	button1 = ADD,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 512,
	editBoxWidth = 260,
	OnShow = function(self,item)
		self.editBox:SetFocus();
	end,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		text = text and text:match("(%d+).-$");
		mog:AddToPreview(tonumber(text));
	end,
	OnCancel = function(self) end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetText();
		text = text and text:match("(%d+).-$");
		mog:AddToPreview(tonumber(text));
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

StaticPopupDialogs["MOGIT_PREVIEW_IMPORT"] = {
	text = L["Copy and paste a Wowhead Compare URL into the text box below to import"],
	button1 = L["Import"],
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 512,
	editBoxWidth = 260,
	OnShow = function(self,item)
		local str;
		for k,v in pairs(mog.view.slots) do
			if v.item then
				if str then
					str = str..":"..v.item;
				else
					str = L["http://www.wowhead.com/"].."compare?items="..v.item;
				end
			end
		end
		self.editBox:SetText(str or "");
		self.editBox:SetFocus();
		self.editBox:HighlightText();
	end,
	OnAccept = function(self)
		local items = self.editBox:GetText();
		items = items and items:match("compare%?items=([^;#]+)");
		if items then
			for item in items:gmatch("([^:]+)") do
				item = item:match("^(%d+)");
				if item then
					mog:AddToPreview(tonumber(item),true);
				end
			end
			if mog.db.profile.gridDress then
				mog.scroll:update();
			end
		end
	end,
	OnCancel = function(self) end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide();
		local items = self:GetText();
		items = items and items:match("compare%?items=([^;#]+)");
		if items then
			for item in items:gmatch("([^:]+)") do
				item = item:match("^(%d+)");
				if item then
					mog:AddToPreview(tonumber(item),true);
				end
			end
			if mog.db.profile.gridDress then
				mog.scroll:update();
			end
		end
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};