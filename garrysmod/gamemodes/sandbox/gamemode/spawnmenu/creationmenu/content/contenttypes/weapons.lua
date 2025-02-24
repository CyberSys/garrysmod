
hook.Add( "PopulateWeapons", "AddWeaponContent", function( pnlContent, tree, browseNode )

	-- Loop through the weapons and add them to the menu
	local Weapons = list.Get( "Weapon" )
	local Categorised = {}

	-- Build into categories
	for k, weapon in pairs( Weapons ) do

		if ( !weapon.Spawnable ) then continue end

		local Category = weapon.Category or "Other2"
		if ( !isstring( Category ) ) then Category = tostring( Category ) end

		Categorised[ Category ] = Categorised[ Category ] or {}
		table.insert( Categorised[ Category ], weapon )

	end

	Weapons = nil

	-- Loop through each category
	local CustomIcons = list.Get( "ContentCategoryIcons" )
	for CategoryName, v in SortedPairs( Categorised ) do

		-- Add a node to the tree
		local node = tree:AddNode( CategoryName, CustomIcons[ CategoryName ] or "icon16/gun.png" )

		-- When we click on the node - populate it using this function
		node.DoPopulate = function( self )

			-- If we've already populated it - forget it.
			if ( self.PropPanel ) then return end

			-- Create the container panel
			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do

				spawnmenu.CreateContentIcon( ent.ScriptedEntityType or "weapon", self.PropPanel, {
					nicename	= ent.PrintName or ent.ClassName,
					spawnname	= ent.ClassName,
					material	= ent.IconOverride or "entities/" .. ent.ClassName .. ".png",
					admin		= ent.AdminOnly
				} )

			end

		end

		-- If we click on the node populate it and switch to it.
		node.DoClick = function( self )

			self:DoPopulate()
			pnlContent:SwitchPanel( self.PropPanel )

		end

	end

	-- Select the first node
	local FirstNode = tree:Root():GetChildNode( 0 )
	if ( IsValid( FirstNode ) ) then
		FirstNode:InternalDoClick()
	end

end )

spawnmenu.AddCreationTab( "#spawnmenu.category.weapons", function()

	local ctrl = vgui.Create( "SpawnmenuContentPanel" )
	ctrl:EnableSearch( "weapons", "PopulateWeapons" )
	ctrl:CallPopulateHook( "PopulateWeapons" )
	return ctrl

end, "icon16/gun.png", 10 )
