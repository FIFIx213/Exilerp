ESX = nil
TriggerEvent("hypex:getTwojStarySharedTwojaStaraObject", function(obj) ESX = obj end)

function doesPlayerHavePerms(player, type)
    if IsPlayerAceAllowed(player, "easyadmin."..type) then
		return true
	end
    return false
end

local banning = {}
RegisterServerEvent("csskrouble:banPlr", function(id, d, rsn) 
    local src = source
    if tonumber(src) ~= nil then
      TriggerEvent("csskrouble:banPlr", "nigger", src, "Tried to ban player (ExileAC)")
    else
        src = d
        if banning[src] then return end
        banning[src] = true
        if tonumber(src) ~= nil or tonumber(src) ~= 0 then  
            local reason = rsn
            if id ~= "nigger" then
                reason = "Trigger detected"
            end
            local license, identifier, liveid, xblid, discord, playerip = "nieznane", "nieznane", "nieznane", "nieznane", "nieznane", "nieznane"
            local targetName = GetPlayerName(src)
            local tokens = {}
            for i = 0, GetNumPlayerTokens(src) - 1 do 
                table.insert(tokens, GetPlayerToken(src, i))
            end
            tokens = json.encode(tokens)
            local bannedby = "ExileAC"
            
            local currentDate = os.date("%d", os.time()) .. "." .. os.date("%m", os.time()) .. "." .. os.date("%Y", os.time()) .. " " .. os.date("%H", os.time()) .. ":" .. os.date("%M", os.time())
            local unixDuration = -1
        
            for k,v in ipairs(GetPlayerIdentifiers(src))do
                if string.sub(v, 1, string.len("license:")) == "license:" then
                    license = v
                elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
                    identifier = v
                elseif string.sub(v, 1, string.len("live:")) == "live:" then
                    liveid = v
                elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
                    xblid  = v
                elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
                    discord = v
                elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
                    playerip = v
                end
            end
            MySQL.Async.execute("UPDATE exile_bans SET reason=@reason, expired=@expired, bannedby=@bannedby, isBanned=1 WHERE license=@license", {
                ["@identifier"] = identifier,
                ["@license"] = license,
                ["@playerip"] = playerip,
                ["@name"] = targetName,
                ["@discord"] = discord,
                ["@hwid"] = tokens,
                ["@reason"] = "Cheating",
                ["@live"] = liveid,
                ["@xbl"] = xblid,
                ["@expired"] = unixDuration,
                ["@bannedby"] = bannedby
                
            }, function (rowsChanged)
                exports["exile_queue"]:AddBan({
                    identifier = identifier,
                    license = license,
                    playerip = playerip,
                    name = targetName,
                    discord = discord,
                    hwid = tokens,
                    reason = "Cheating",
                    added = currentDate,
                    live = liveid,
                    xbl = xblid,
                    expired = unixDuration,
                    bannedby = bannedby,
										isbanned = "1"
                })
                local date = os.date("*t")			
                if date.month < 10 then date.month = "0" .. tostring(date.month) end
                if date.day < 10 then date.day = "0" .. tostring(date.day) end
                if date.hour < 10 then date.hour = "0" .. tostring(date.hour) end
                if date.min < 10 then date.min = "0" .. tostring(date.min) end
                if date.sec < 10 then date.sec = "0" .. tostring(date.sec) end
                local date = (""..date.day .. "." .. date.month .. "." .. date.year .. " - " .. date.hour .. ":" .. date.min .. ":" .. date.sec.."")
                local daneString = string.format("Rockstar: %s\nSteam: %s\nDiscord: %s\nLive: %s\nXBL: %s", license, identifier,discord,liveid,xblid)
                local tekst = string.format("```\nKto: %s\nPrzez: Exile Anticheat\nPowód: Cheating [%s]\nData: %s\nDane: \n%s\nSerwer: %s\n```", targetName, reason, date, daneString, "WL OFF")
                    
                PerformHttpRequest(Config.BanWebhook, function(err, text, headers) end, "POST", json.encode({username = "Exile Anticheat", content = tekst}), { ["Content-Type"] = "application/json" })
                banning[src] = false
            end)
            TriggerClientEvent("csskrouble:crash", src)
        end
    end    
end)

RegisterServerEvent("csskroubleAC:gotMeDMG", function(z) 
	local src = source
	TriggerEvent("csskrouble:banPlr", "nigger", src, "Detection: "..z.." (Mods)")
end)

local payCheckStrikes = {}
local payCheckEvent = "csskroubleAC:payCheck"
RegisterServerEvent(payCheckEvent, function(id) 
	local src = source
	if tonumber(src) ~= nil then
		TriggerEvent("csskrouble:banPlr", "nigger", src, "Detection: Event "..payCheckEvent.." detected")
	else
		if payCheckStrikes[id] == nil then
			payCheckStrikes[id] = 1
		else
			payCheckStrikes[id] = payCheckStrikes[id]+1
			local strikes = payCheckStrikes[id]
			if strikes > 5 then
				TriggerEvent("csskrouble:banPlr", "nigger", id, "Detection: Paycheck spam detected, `"..strikes.."` in a row")
			else
				Citizen.SetTimeout(5000, function() 
					payCheckStrikes[id] = payCheckStrikes[id]-1
				end)
			end
		end
	end
end)

local screenKeys = {
	["DELETE"] = 214, ["INSERT"] = 121, ["HOME"] = 212, ["NUMPAD7"] = 117
}
function checkKey(key) 
	local a = "n/a"
	for k,v in pairs(screenKeys) do
		if v == key then
			a = k
			break
		end
	end
	return a
end

function getPlayerData(src) 
	local license = "nieznana"
	for k,v in pairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len("license:")) == "license:" then
			license = v
		end
	end
	return src.." - "..string.gsub(license, "license:", "").." - "..GetPlayerName(src)
end

function getFooter() 
	local date = os.date("*t")			
	if date.month < 10 then date.month = "0" .. tostring(date.month) end
	if date.day < 10 then date.day = "0" .. tostring(date.day) end
	if date.hour < 10 then date.hour = "0" .. tostring(date.hour) end
	if date.min < 10 then date.min = "0" .. tostring(date.min) end
	if date.sec < 10 then date.sec = "0" .. tostring(date.sec) end
	local date = (""..date.day .. "." .. date.month .. "." .. date.year .. " - " .. date.hour .. ":" .. date.min .. ":" .. date.sec.."")
	return "csskroubleAC - "..date
end

-- JEBAĆ JANIAKA, VILLISA I JEGO EVENT
--[[
AddEventHandler('explosionEvent', function(source, ev)
	local src = source
	if ev and ev.explosionType and ev.damageScale ~= 0.0 and ev.ownerNetId == 0 and ev.explosionType ~= 13 then
		exports['exile_logs']:SendLog(src, "Próbował wywołać eksplozję: `"..ev.explosionType.."`", 'anticheat')
	end
	CancelEvent()
end)]]

local whTimeout = {}
RegisterNetEvent("csskrouble:sendScreen", function(ss, key, count) 
	local src = source
	if whTimeout[src] then return end
	if string.find(ss, "cdn.discordapp.com") or string.find(ss, "cdn.discord.com") then
		local embed = {
			{
					["color"] = 5793266,
					["title"] = getPlayerData(src),
					["description"] = "Naciśnięto zablokowany klawisz: `"..checkKey(key).."`\nŁączna ilość screenshotów podczas sesji: `"..count.."`",
					["image"] = {
						["url"] = ss
					},
					["footer"] = {
							["text"] = getFooter(),
					},
			}
		}
		print("^3[csskroubleAC] ^7Sending ^3INSERT^7 webhook for player ^3"..GetPlayerName(src).."^7")
		PerformHttpRequest(Config.InsertWebhook, function(err, text, headers) end, "POST", json.encode({username = "csskroubleAC", embeds = embed}), { ["Content-Type"] = "application/json" })
		whTimeout[src] = true
		Citizen.SetTimeout(4000, function ()
			whTimeout[src] = false
		end)
	end
end)

RegisterServerEvent("exile:sendnibba")
AddEventHandler("exile:sendnibba", function(type, arg, skrypt)
	local _source = source
	if not doesPlayerHavePerms(_source, type) then
		TriggerEvent("csskrouble:banPlr", "nigger", _source, string.format("Injection in script %s (Exile-Handler)", skrypt))
	end
end)

--[[local entities = {
	Vehicles = {
		[`FBI`] = true,
		[`FBI2`] = true,
		[`POLICE`] = true,
		[`POLICE2`] = true,
		[`POLICE3`] = true,
		[`POLICE4`] = true,
		[`POLICEB`] = true,
		[`POLICEOLD1`] = true,
		[`POLICEOLD2`] = true,
		[`PRANGER`] = true,
		[`SHERIFF`] = true,
		[`SHERIFF2`] = true,
		[`FIRETRUCK`] = true,
		[`FIRETRUK`] = true,
		[`VALKYRIE`] = true,
		[`VALKYRIE2`] = true,
		[`SWIFT`] = true,
		[`SWIFT2`] = true,
		[`SKYLIFT`] = true,
		[`SAVAGE`] = true,
		[`CUBAN800`] = true,
		[`DUSTER`] = true,
		[`BUZZARD`] = true,
		[`BUZZARD2`] = true,
		[`ANNIHILATOR`] = true,
		[`FROGGER`] = true,
		[`SUPERVOLITO`] = true,
		[`HYDRA`] = true,
		[`LAZER`] = true,
		[`OPRESSOR2`] = true,
		[`CARGOPLANE`] = true,
		[`DUNE3`] = true,
		[`BLIMP`] = true,
		[`BLIMP2`] = true,
		[`BLIMP3`] = true,
		[`JET`] = true,
		[`DUSTER`] = true,
		[`VELUM`] = true,
		[`TITAN`] = true,
		[`STUNT`] = true,
		[`DODO`] = true,
		[`MONSTER`] = true,
		[`MARSHALL`] = true,
		[`DUNE2`] = true,
		[`DUMP`] = true,
		[`CUTTER`] = true,
		[`ambulance`] = true,
		[`ambulance2`] = true,
		[`ambulance3`] = true,
		[`police`] = true,
		[`police2`] = true,
		[`police3`] = true,
		[`police4`] = true,
		[`rhino`] = true,
		[`besra`] = true,
		[`akula`] = true,
		[`savage`] = true,
		[`hunter`] = true,
		[`buzzard`] = true,
		[`buzzard`] = true,
		[`annihilator`] = true,
		[`annihilator2`] = false, -------
		[`valkyrie`] = true,
		[`valkyrie2`] = true,
		[`hydra`] = true,
		[`apc`] = true,
		[`Trailersmall2`] = true,
		[`Lazer`] = true,
		[`oppressor`] = true,
		[`mogul`] = true,
		[`barrage`] = true,
		[`volatol`] = true,
		[`chernobog`] = true,
		[`avenger`] = true,
		[`stromberg`] = true,
		[`nightshark`] = true,
		[`babushka`] = true,
		[`starling`] = true,
		[`insurgent`] = true,
		[`cargobob`] = true,
		[`cargobob2`] = true,
		[`cargobob3`] = true,
		[`cargobob4`] = false, --
		[`caracara`] = true,
		[`deluxo`] = true,
		[`menacer`] = true,
		[`scramjet`] = true,
		[`oppressor2`] = true,
		[`revolter`] = true,
		[`viseris`] = true,
		[`savestra`] = true,
		[`thruster`] = true,
		[`ardent`] = true,
		[`dune3`] = true,
		[`tampa3`] = true,
		[`halftrack`] = true,
		[`nokota`] = true,
		[`strikeforce`] = true,
		[`bombushka`] = true,
		[`molotok`] = true,
		[`pyro`] = true,
		[`ruiner2`] = true,
		[`limo2`] = true,
		[`technical`] = true,
		[`technical2`] = true,
		[`technical3`] = true,
		[`jb700w`] = true,
		[`blazer5`] = true,
		[`boxville5`] = true,
		[`bruiser`] = true,
		[`bruiser2`] = true,
		[`bruiser3`] = true,
		[`brutus`] = true,
		[`brutus2`] = true,
		[`brutus3`] = true,
		[`cerberus`] = true,
		[`cerberus2`] = true,
		[`cerberus3`] = true,
		[`dominator4`] = true,
		[`dominator5`] = true,
		[`dominator6`] = true,
		[`impaler2`] = true,
		[`impaler3`] = true,
		[`impaler4`] = true,
		[`imperator`] = true,
		[`imperator2`] = true,
		[`imperator3`] = true,
		[`issi4`] = true,
		[`issi5`] = true,
		[`issi6`] = true,
		[`monster3`] = true,
		[`monster4`] = true,
		[`monster5`] = true,
		[`scarab`] = true,
		[`scarab2`] = true,
		[`scarab3`] = true,
		[`slamvan4`] = true,
		[`slamvan5`] = true,
		[`slamvan6`] = true,
		[`zr380`] = true,
		[`zr3802`] = true,
		[`zr3803`] = true,
		[`alphaz1`] = true,
		[`avenger2`] = true,
		[`blimp`] = true,
		[`blimp2`] = true,
		[`blimp3`] = true,
		[`cargoplane`] = true,
		[`cuban800`] = true,
		[`dodo`] = true,
		[`duster`] = true,
		[`howard`] = true,
		[`jet`] = true,
		[`luxor2`] = true,
		[`mammatus`] = true,
		[`miljet`] = true,
		[`nimbus`] = true,
		[`rogue`] = true,
		[`seabreeze`] = true,
		[`shamal`] = true,
		[`stunt`] = true,
		[`titan`] = true,
		[`tula`] = true,
		[`velum`] = true,
		[`velum2`] = true,
		[`frogger`] = true,
		[`freight`] = true,
		[`freightcar`] = true,
		[`freightcont1`] = true,
		[`freightcont2`] = true,
		[`freightgrain`] = true,
		[`freighttrailer`] = true,
		[`tankercar`] = true,
		[`liberator`] = true,
		[`liberator2`] = true,
		[`liberator3`] = true,
	},

	Objects = {
		`a_m_o_acult_01`,
		`apa_mp_apa_crashed_usaf_01a`,
		`apa_mp_apa_yacht`,
		`apa_mp_apa_yacht_door2`,
		`apa_mp_apa_yacht_door`,
		`apa_mp_apa_yacht_jacuzzi_cam`,
		`apa_mp_apa_yacht_jacuzzi_ripple003`,
		`apa_mp_apa_yacht_jacuzzi_ripple1`,
		`apa_mp_apa_yacht_jacuzzi_ripple2`,
		`apa_mp_apa_yacht_o1_rail_a`,
		`apa_mp_apa_yacht_o1_rail_b`,
		`apa_mp_apa_yacht_o2_rail_a`,
		`apa_mp_apa_yacht_o2_rail_b`,
		`apa_mp_apa_yacht_o3_rail_a`,
		`apa_mp_apa_yacht_o3_rail_b`,
		`apa_mp_apa_yacht_option1`,
		`apa_mp_apa_yacht_option1_cola`,
		`apa_mp_apa_yacht_option2`,
		`apa_mp_apa_yacht_option2_cola`,
		`apa_mp_apa_yacht_option2_colb`,
		`apa_mp_apa_yacht_option3`,
		`apa_mp_apa_yacht_option3_cola`,
		`apa_mp_apa_yacht_option3_colb`,
		`apa_mp_apa_yacht_option3_colc`,
		`apa_mp_apa_yacht_option3_cold`,
		`apa_mp_apa_yacht_option3_cole`,
		`apa_mp_apa_yacht_radar_01a`,
		`apa_mp_apa_yacht_win`,
		`apa_mp_h_yacht_`,
		`apa_mp_h_yacht_armchair_01`,
		`apa_mp_h_yacht_armchair_03`,
		`apa_mp_h_yacht_armchair_04`,
		`apa_mp_h_yacht_barstool_01`,
		`apa_mp_h_yacht_bed_01`,
		`apa_mp_h_yacht_bed_02`,
		`apa_mp_h_yacht_coffee_table_01`,
		`apa_mp_h_yacht_coffee_table_02`,
		`apa_mp_h_yacht_floor_lamp_01`,
		`apa_mp_h_yacht_side_table_01`,
		`apa_mp_h_yacht_side_table_02`,
		`apa_mp_h_yacht_sofa_01`,
		`apa_mp_h_yacht_sofa_02`,
		`apa_mp_h_yacht_stool_01`,
		`apa_mp_h_yacht_strip_chair_01`,
		`apa_mp_h_yacht_table_lamp_01`,
		`apa_mp_h_yacht_table_lamp_02`,
		`apa_mp_h_yacht_table_lamp_03`,
		`apa_prop_yacht_glass_06`,
		`apa_prop_yacht_glass_07`,
		`apa_prop_yacht_glass_08`,
		`apa_prop_yacht_glass_09`,
		`apa_prop_yacht_glass_10`,
		`cargoplane`,
		`ch2_03c_props_rrlwindmill_lod`,
		`ch2_03c_rnchstones_lod`,
		`ch3_04_viewplatform_slod`,
		`cs2_10_sea_rocks_lod`,
		`cs2_10_sea_shipwreck_lod`,
		`cs2_11_sea_marina_xr_rocks_03_lod`,
		`des_shipsink_02`,
		`des_tankercrash_01`,
		`des_tankerexplosion_01`,
		`des_tankerexplosion_02`,
		`des_trailerparka_02`,
		`des_traincrash_root7`,
		`ex_prop_exec_crashdp`,
		`mp_player_int_rock`,
		`mp_player_introck`,
		`p_crahsed_heli_s`,
		`p_spinning_anus_s`,
		`proc_mntn_stone01`,
		`proc_mntn_stone02`,
		`proc_searock_01`,
		`prop_a4_pile_01`,
		`prop_asteroid_01`,
		`prop_beach_fire`,
		`prop_flag_columbia`,
		`prop_flag_eu`,
		`prop_flag_eu_s`,
		`prop_flagpole_1a`,
		`prop_flagpole_2a`,
		`prop_flagpole_3a`,
		`prop_flamingo`,
		`prop_fnclink_05crnr1`,
		`prop_gold_cont_01`,
		`prop_hydro_platform`,
		`prop_player_gasmask`,
		`prop_rock_1_a`,
		`prop_rock_1_b`,
		`prop_rock_1_c`,
		`prop_rock_1_d`,
		`prop_rock_1_e`,
		`prop_rock_1_f`,
		`prop_rock_1_g`,
		`prop_rock_1_h`,
		`prop_rock_4_big2`,
		`prop_shamal_crash`,
		`prop_target_blue_arrow`,
		`prop_target_orange_arrow`,
		`prop_target_purp_arrow`,
		`prop_target_red_arrow`,
		`prop_test_boulder_01`,
		`prop_test_boulder_02`,
		`prop_test_boulder_03`,
		`prop_test_boulder_04`,
		`prop_windmill_01`,
		`prop_xmas_tree_int`,
		`sr_prop_spec_tube_xxs_01a`,
		`stt_prop_race_gantry_01`,
		`stt_prop_race_start_line_01`,
		`stt_prop_race_start_line_01b`,
		`stt_prop_race_start_line_02`,
		`stt_prop_race_start_line_02b`,
		`stt_prop_race_start_line_03`,
		`stt_prop_race_start_line_03b`,
		`stt_prop_race_tannoy`,
		`stt_prop_ramp_adj_flip_m`,
		`stt_prop_ramp_adj_flip_mb`,
		`stt_prop_ramp_adj_flip_s`,
		`stt_prop_ramp_adj_flip_sb`,
		`stt_prop_ramp_adj_hloop`,
		`stt_prop_ramp_adj_loop`,
		`stt_prop_ramp_jump_l`,
		`stt_prop_ramp_jump_m`,
		`stt_prop_ramp_jump_s`,
		`stt_prop_ramp_jump_xl`,
		`stt_prop_ramp_jump_xs`,
		`stt_prop_ramp_jump_xxl`,
		`stt_prop_ramp_multi_loop_rb`,
		`stt_prop_ramp_spiral_l`,
		`stt_prop_ramp_spiral_l_l`,
		`stt_prop_ramp_spiral_l_m`,
		`stt_prop_ramp_spiral_l_s`,
		`stt_prop_ramp_spiral_l_xxl`,
		`stt_prop_ramp_spiral_m`,
		`stt_prop_ramp_spiral_s`,
		`stt_prop_ramp_spiral_xxl`,
		`stt_prop_stunt_bowling_ball`,
		`stt_prop_stunt_bowling_pin`,
		`stt_prop_stunt_domino`,
		`stt_prop_stunt_jump15`,
		`stt_prop_stunt_jump30`,
		`stt_prop_stunt_jump45`,
		`stt_prop_stunt_jump_l`,
		`stt_prop_stunt_jump_lb`,
		`stt_prop_stunt_jump_loop`,
		`stt_prop_stunt_jump_m`,
		`stt_prop_stunt_jump_mb`,
		`stt_prop_stunt_jump_s`,
		`stt_prop_stunt_jump_sb`,
		`stt_prop_stunt_landing_zone_01`,
		`stt_prop_stunt_ramp`,
		`stt_prop_stunt_soccer_ball`,
		`stt_prop_stunt_soccer_goal`,
		`stt_prop_stunt_soccer_lball`,
		`stt_prop_stunt_soccer_sball`,
		`stt_prop_stunt_target`,
		`stt_prop_stunt_target_small`,
		`stt_prop_stunt_track_bumps`,
		`stt_prop_stunt_track_cutout`,
		`stt_prop_stunt_track_dwlink`,
		`stt_prop_stunt_track_dwlink_02`,
		`stt_prop_stunt_track_dwsh15`,
		`stt_prop_stunt_track_dwshort`,
		`stt_prop_stunt_track_dwslope15`,
		`stt_prop_stunt_track_dwslope30`,
		`stt_prop_stunt_tube_fn_01`,
		`stt_prop_stunt_tube_fn_02`,
		`stt_prop_stunt_tube_fn_03`,
		`stt_prop_stunt_tube_fn_04`,
		`stt_prop_stunt_tube_fn_05`,
		`stt_prop_stunt_tube_jmp2`,
		`stt_prop_track_stop_sign`,
		`xm_prop_x17_shamal_crash`,
		`xm_prop_x17_xmas_tree_int`,
		`xs3_prop_int_xmas_tree_01`,
		`xs_prop_hamburgher_wl`,
		`xs_prop_plastic_bottle_wl`,
		`xs_propintxmas_tree_2018`,
		`a_c_boar`,
		`a_c_cat_01`,
		`a_c_chickenhawk`,
		`a_c_chimp`,
		`a_c_chop`,
		`a_c_cormorant`,
		`a_c_cow`,
		`a_c_coyote`,
		`a_c_crow`,
		`a_c_dolphin`,
		`a_c_fish`,
		`a_c_hen`,
		`a_c_humpback`,
		`a_c_husky`,
		`a_c_killerwhale`,
		`a_c_mtlion`,
		`a_c_pigeon`,
		`a_c_poodle`,
		`a_c_pug`,
		`a_c_rabbit_01`,
		`a_c_rat`,
		`a_c_retriever`,
		`a_c_rhesus`,
		`a_c_rottweiler`,
		`a_c_sharkhammer`,
		`a_c_sharktiger`,
		`a_c_shepherd`,
		`a_c_stingray`,
		`a_c_westy`,
		`a_f_y_topless_01`,
		`A_M_Y_ACult_01`,
		`apa_mp_apa_yacht`,
		`apa_prop_flag_argentina`,
		`apa_prop_flag_australia`,
		`apa_prop_flag_austria`,
		`apa_prop_flag_belgium`,
		`apa_prop_flag_brazil`,
		`apa_prop_flag_canada_yt`,
		`apa_prop_flag_canadat_yt`,
		`apa_prop_flag_china`,
		`apa_prop_flag_columbia`,
		`apa_prop_flag_croatia`,
		`apa_prop_flag_czechrep`,
		`apa_prop_flag_denmark`,
		`apa_prop_flag_england`,
		`apa_prop_flag_eu_yt`,
		`apa_prop_flag_finland`,
		`apa_prop_flag_france`,
		`apa_prop_flag_german_yt`,
		`apa_prop_flag_hungary`,
		`apa_prop_flag_ireland`,
		`apa_prop_flag_israel`,
		`apa_prop_flag_italy`,
		`apa_prop_flag_jamaica`,
		`apa_prop_flag_japan_yt`,
		`apa_prop_flag_lstein`,
		`apa_prop_flag_malta`,
		`apa_prop_flag_mexico_yt`,
		`apa_prop_flag_netherlands`,
		`apa_prop_flag_newzealand`,
		`apa_prop_flag_nigeria`,
		`apa_prop_flag_norway`,
		`apa_prop_flag_palestine`,
		`apa_prop_flag_poland`,
		`apa_prop_flag_portugal`,
		`apa_prop_flag_puertorico`,
		`apa_prop_flag_russia_yt`,
		`apa_prop_flag_scotland_yt`,
		`apa_prop_flag_script`,
		`apa_prop_flag_slovakia`,
		`apa_prop_flag_slovenia`,
		`apa_prop_flag_southafrica`,
		`apa_prop_flag_southkorea`,
		`apa_prop_flag_spain`,
		`apa_prop_flag_sweden`,
		`apa_prop_flag_switzerland`,
		`apa_prop_flag_turkey`,
		`apa_prop_flag_uk_yt`,
		`apa_prop_flag_us_yt`,
		`apa_prop_flag_wales`,
		`apa_prop_yacht_float_1a`,
		`apa_prop_yacht_float_1b`,
		`apa_prop_yacht_glass_01`,
		`apa_prop_yacht_glass_02`,
		`apa_prop_yacht_glass_03`,
		`apa_prop_yacht_glass_04`,
		`apa_prop_yacht_glass_05`,
		`apa_prop_yacht_glass_06`,
		`apa_prop_yacht_glass_07`,
		`apa_prop_yacht_glass_08`,
		`apa_prop_yacht_glass_09`,
		`apa_prop_yacht_glass_10`,
		`bkr_prop_biker_bblock_huge_01`,
		`bkr_prop_biker_bblock_huge_02`,
		`bkr_prop_biker_bblock_huge_04`,
		`bkr_prop_biker_bblock_huge_05`,
		`cargoplane`,
		`ch2_03c_props_rrlwindmill_lod`,
		`ch2_03c_rnchstones_lod`,
		`ch3_03_cliffrocks03b_lod`,
		`ch3_04_rock_lod_02`,
		`ch3_04_viewplatform_slod`,
		`ch3_12_animplane1_lod`,
		`ch3_12_animplane2_lod`,
		`cs1_09_sea_ufo`,
		`cs2_10_sea_rocks_lod`,
		`cs2_10_sea_shipwreck_lod`,
		`cs2_11_sea_marina_xr_rocks_03_lod`,
		`cs3_08b_rsn_db_aliencover_0001cs3_08b_rsn_db_aliencover_0001_a`,
		`CS_Orleans`,
		`csx_coastboulder_00`,
		`csx_coastboulder_01`,
		`csx_coastboulder_02`,
		`csx_coastboulder_03`,
		`csx_coastboulder_04`,
		`csx_coastboulder_05`,
		`csx_coastboulder_06`,
		`csx_coastboulder_07`,
		`csx_coastrok1`,
		`csx_coastrok2`,
		`csx_coastrok3`,
		`csx_coastrok4`,
		`csx_coastsmalrock_01`,
		`csx_coastsmalrock_01_`,
		`csx_coastsmalrock_02`,
		`csx_coastsmalrock_02_`,
		`csx_coastsmalrock_03`,
		`csx_coastsmalrock_03_`,
		`csx_coastsmalrock_04`,
		`csx_coastsmalrock_04_`,
		`csx_coastsmalrock_05`,
		`csx_coastsmalrock_05_`,
		`csx_searocks_02`,
		`csx_searocks_03`,
		`csx_searocks_04`,
		`csx_searocks_05`,
		`csx_searocks_06`,
		`des_finale_vault_end`,
		`des_finale_vault_root001`,
		`des_finale_vault_root002`,
		`des_finale_vault_root003`,
		`des_finale_vault_root004`,
		`des_finale_vault_start`,
		`des_shipsink_02`,
		`des_shipsink_03`,
		`des_shipsink_04`,
		`des_tankercrash_01`,
		`des_tankerexplosion_01`,
		`des_tankerexplosion_02`,
		`des_trailerparka_02`,
		`des_trailerparkb_02`,
		`des_trailerparkc_02`,
		`des_trailerparkd_02`,
		`des_traincrash_root2`,
		`des_traincrash_root3`,
		`des_traincrash_root4`,
		`des_traincrash_root5`,
		`des_traincrash_root6`,
		`des_traincrash_root7`,
		`des_vaultdoor001_root001`,
		`des_vaultdoor001_root002`,
		`des_vaultdoor001_root003`,
		`des_vaultdoor001_root004`,
		`des_vaultdoor001_root005`,
		`des_vaultdoor001_root006`,
		`des_vaultdoor001_skin001`,
		`des_vaultdoor001_start`,
		`ex_prop_exec_crashdp`,
		`FreemodeFemale01`,
		`FreeModeMale01`,
		`hei_prop_carrier_defense_01`,
		`hei_prop_carrier_jet`,
		`hei_prop_carrier_radar_1`,
		`hei_prop_carrier_radar_1_l1`,
		`hei_prop_hei_pic_pb_plane`,
		`hei_prop_heist_emp`,
		`hei_prop_heist_hook_01`,
		`hei_prop_heist_tug`,
		`Heist_Yacht`,
		`hw1_blimp_ce2`,
		`hw1_blimp_ce2_lod`,
		`hw1_blimp_ce_lod`,
		`hw1_blimp_cpr003`,
		`hw1_blimp_cpr_null2`,
		`hw1_blimp_cpr_null`,
		`jet`,
		`light_plane_rig`,
		`marina_xr_rocks_02`,
		`marina_xr_rocks_03`,
		`marina_xr_rocks_04`,
		`marina_xr_rocks_05`,
		`marina_xr_rocks_06`,
		`maverick`,
		`Miljet`,
		`mp_player_int_rock`,
		`mp_player_introck`,
		`p_cablecar_s`,
		`p_crahsed_heli_s`,
		`p_crahsed_heli_s`,
		`p_cs_mp_jet_01_s`,
		`p_cs_sub_hook_01_s`,
		`p_fib_rubble_s`,
		`p_fin_vaultdoor_s`,
		`p_gasmask_s`,
		`p_ld_soc_ball_01`,
		`p_med_jet_01_s`,
		`p_oil_pjack_01_amo`,
		`p_oil_pjack_01_s`,
		`p_oil_pjack_02_amo`,
		`p_oil_pjack_02_s`,
		`p_oil_pjack_03_amo`,
		`p_oil_pjack_03_s`,
		`p_oil_slick_01`,
		`p_parachute1_s`,
		`p_spinning_anus_s`,
		`P_Spinning_Anus_S_Main`,
		`P_Spinning_Anus_S_Root`,
		`p_tram_cash_s`,
		`p_tram_crash_s`,
		`p_yacht_chair_01_s`,
		`p_yacht_sofa_01_s`,
		`proc_mntn_stone01`,
		`proc_mntn_stone02`,
		`proc_mntn_stone03`,
		`proc_searock_01`,
		`proc_sml_stones01`,
		`proc_sml_stones02`,
		`proc_sml_stones03`,
		`proc_stones_01`,
		`proc_stones_02`,
		`proc_stones_03`,
		`proc_stones_04`,
		`proc_stones_05`,
		`proc_stones_06`,
		`prop_a4_pile_01`,
		`prop_air_bigradar`,
		`prop_air_bigradar_l1`,
		`prop_air_bigradar_l2`,
		`prop_air_bigradar_slod`,
		`prop_air_radar_01`,
		`prop_aircon_l_03`,
		`prop_aircon_m_04`,
		`prop_asteroid_01`,
		`prop_bank_vaultdoor`,
		`prop_beach_fire`,
		`prop_beachflag_le`,
		`prop_cable_hook_01`,
		`prop_carrier_radar_1_l1`,
		`prop_coathook_01`,
		`prop_container_01a`,
		`prop_coral_stone_03`,
		`prop_coral_stone_04`,
		`prop_crashed_heli`,
		`prop_cs_plane_int_01`,
		`prop_cs_sub_hook_01`,
		`prop_dock_crane_02_hook`,
		`prop_dock_shippad`,
		`prop_dummy_01`,
		`prop_dummy_plane`,
		`prop_fire_exting_1a`,
		`prop_fire_exting_1b`,
		`prop_fire_exting_2a`,
		`prop_fire_exting_3a`,
		`prop_flag_canada`,
		`prop_flag_canada_s`,
		`prop_flag_columbia`,
		`prop_flag_eu`,
		`prop_flag_eu_s`,
		`prop_flag_france`,
		`prop_flag_france_s`,
		`prop_flag_german`,
		`prop_flag_german_s`,
		`prop_flag_ireland`,
		`prop_flag_ireland_s`,
		`prop_flag_japan`,
		`prop_flag_japan_s`,
		`prop_flag_ls`,
		`prop_flag_ls_s`,
		`prop_flag_lsfd`,
		`prop_flag_lsfd_s`,
		`prop_flag_lsservices`,
		`prop_flag_lsservices_s`,
		`prop_flag_mexico`,
		`prop_flag_mexico_s`,
		`prop_flag_russia`,
		`prop_flag_russia_s`,
		`prop_flag_s`,
		`prop_flag_sa`,
		`prop_flag_sa_s`,
		`prop_flag_sapd`,
		`prop_flag_sapd_s`,
		`prop_flag_scotland`,
		`prop_flag_scotland_s`,
		`prop_flag_sheriff`,
		`prop_flag_sheriff_s`,
		`prop_flag_uk`,
		`prop_flag_uk_s`,
		`prop_flag_us`,
		`prop_flag_us_r`,
		`prop_flag_us_s`,
		`prop_flag_usboat`,
		`prop_flagpole_1a`,
		`prop_flagpole_2a`,
		`prop_flagpole_2b`,
		`prop_flagpole_2c`,
		`prop_flagpole_3a`,
		`prop_flamingo`,
		`prop_fnclink_05crnr1`,
		`prop_fnclink_05crnr1`,
		`prop_gold_cont_01`,
		`prop_gold_vault_fence_l`,
		`prop_gold_vault_fence_r`,
		`prop_gold_vault_gate_01`,
		`prop_gravestones_01a`,
		`prop_gravestones_02a`,
		`prop_gravestones_03a`,
		`prop_gravestones_04a`,
		`prop_gravestones_05a`,
		`prop_gravestones_06a`,
		`prop_gravestones_07a`,
		`prop_gravestones_08a`,
		`prop_gravestones_09a`,
		`prop_gravestones_10a`,
		`prop_hydro_platform`,
		`prop_juicestand`,
		`prop_Ld_ferris_wheel`,
		`prop_ld_hook`,
		`prop_ld_vault_door`,
		`prop_lev_des_barage_02`,
		`prop_lev_des_barge_01`,
		`prop_lev_des_barge_02`,
		`prop_med_jet_01`,
		`prop_mk_flag`,
		`prop_mk_flag_2`,
		`prop_mk_plane`,
		`prop_money_bag_01`,
		`prop_mp_ramp_03`,
		`prop_planer_01`,
		`prop_player_gasmask`,
		`prop_poly_bag_money`,
		`prop_prlg_gravestone_01a`,
		`prop_prlg_gravestone_02a`,
		`prop_prlg_gravestone_03a`,
		`prop_prlg_gravestone_04a`,
		`prop_prlg_gravestone_05a`,
		`prop_prlg_gravestone_05a_l1`,
		`prop_prlg_gravestone_06a`,
		`prop_rock_1_a`,
		`prop_rock_1_b`,
		`prop_rock_1_c`,
		`prop_rock_1_d`,
		`prop_rock_1_e`,
		`prop_rock_1_f`,
		`prop_rock_1_g`,
		`prop_rock_1_h`,
		`prop_rock_4_big2`,
		`prop_rock_4_big2`,
		`prop_rope_hook_01`,
		`prop_sculpt_fix`,
		`prop_shamal_crash`,
		`prop_stoneshroom1`,
		`prop_stoneshroom2`,
		`prop_sub_crane_hook`,
		`prop_swiss_ball_01`,
		`prop_target_blue_arrow`,
		`prop_target_orange_arrow`,
		`prop_target_purp_arrow`,
		`prop_target_red_arrow`,
		`prop_test_boulder_01`,
		`prop_test_boulder_02`,
		`prop_test_boulder_03`,
		`prop_test_boulder_04`,
		`prop_test_rocks01`,
		`prop_test_rocks02`,
		`prop_test_rocks03`,
		`prop_test_rocks04`,
		`prop_v_hook_s`,
		`prop_vault_door_scene`,
		`prop_vault_shutter`,
		`prop_vehicle_hook`,
		`prop_weed_01`,
		`prop_winch_hook_long`,
		`prop_winch_hook_short`,
		`prop_windmill_01`,
		`prop_windmill_01`,
		`prop_windmill_01_I1`,
		`prop_windmill_01_slod2`,
		`prop_windmill_01_slod`,
		`prop_xmas_ext`,
		`prop_yacht_lounger`,
		`prop_yacht_seat_01`,
		`prop_yacht_seat_02`,
		`prop_yacht_seat_03`,
		`prop_yacht_table_01`,
		`prop_yacht_table_02`,
		`prop_yacht_table_03`,
		`rnbj_wallsigns_0001`,
		`rsn_os_specialfloaty2`,
		`rsn_os_specialfloaty2_light2`,
		`rsn_os_specialfloaty2_light`,
		`rsn_os_specialfloatymetal`,
		`rsn_os_specialfloatymetal_n`,
		`s_f_y_hooker_01`,
		`s_f_y_hooker_03`,
		`S_M_M_MovAlien_01`,
		`s_m_m_movalien_01`,
		`s_m_m_movallien_01`,
		`S_M_M_MovSpace_01`,
		`s_m_y_blackops_01`,
		`sc1_04_rnmo_paintoverlaysc1_04_rnmo_paintoverlay_a`,
		`stt_prop_c4_stack`,
		`stt_prop_corner_sign_01`,
		`stt_prop_corner_sign_02`,
		`stt_prop_corner_sign_03`,
		`stt_prop_corner_sign_04`,
		`stt_prop_corner_sign_05`,
		`stt_prop_corner_sign_06`,
		`stt_prop_corner_sign_07`,
		`stt_prop_corner_sign_08`,
		`stt_prop_corner_sign_09`,
		`stt_prop_corner_sign_10`,
		`stt_prop_corner_sign_11`,
		`stt_prop_corner_sign_12`,
		`stt_prop_corner_sign_13`,
		`stt_prop_corner_sign_14`,
		`stt_prop_flagpole_1a`,
		`stt_prop_flagpole_1b`,
		`stt_prop_flagpole_1c`,
		`stt_prop_flagpole_1d`,
		`stt_prop_flagpole_1e`,
		`stt_prop_flagpole_1f`,
		`stt_prop_flagpole_2a`,
		`stt_prop_flagpole_2b`,
		`stt_prop_flagpole_2c`,
		`stt_prop_flagpole_2d`,
		`stt_prop_flagpole_2e`,
		`stt_prop_flagpole_2f`,
		`stt_prop_hoop_constraction_01a`,
		`stt_prop_hoop_small_01`,
		`stt_prop_hoop_tyre_01a`,
		`stt_prop_lives_bottle`,
		`stt_prop_sign_circuit_01`,
		`stt_prop_sign_circuit_02`,
		`stt_prop_sign_circuit_03`,
		`stt_prop_sign_circuit_04`,
		`stt_prop_sign_circuit_05`,
		`stt_prop_sign_circuit_06`,
		`stt_prop_sign_circuit_07`,
		`stt_prop_sign_circuit_08`,
		`stt_prop_sign_circuit_09`,
		`stt_prop_sign_circuit_10`,
		`stt_prop_sign_circuit_11`,
		`stt_prop_sign_circuit_11b`,
		`stt_prop_sign_circuit_12`,
		`stt_prop_sign_circuit_13`,
		`stt_prop_sign_circuit_13b`,
		`stt_prop_sign_circuit_14`,
		`stt_prop_sign_circuit_14b`,
		`stt_prop_sign_circuit_15`,
		`stt_prop_slow_down`,
		`stt_prop_speakerstack_01a`,
		`stt_prop_startline_gantry`,
		`stt_prop_stunt_bblock_huge_01`,
		`stt_prop_stunt_bblock_huge_02`,
		`stt_prop_stunt_bblock_huge_03`,
		`stt_prop_stunt_bblock_huge_04`,
		`stt_prop_stunt_bblock_huge_05`,
		`stt_prop_stunt_bblock_hump_01`,
		`stt_prop_stunt_bblock_hump_02`,
		`stt_prop_stunt_bblock_lrg1`,
		`stt_prop_stunt_bblock_lrg2`,
		`stt_prop_stunt_bblock_lrg3`,
		`stt_prop_stunt_bblock_mdm1`,
		`stt_prop_stunt_bblock_mdm2`,
		`stt_prop_stunt_bblock_mdm3`,
		`stt_prop_stunt_bblock_qp2`,
		`stt_prop_stunt_bblock_qp3`,
		`stt_prop_stunt_bblock_qp`,
		`stt_prop_stunt_bblock_sml1`,
		`stt_prop_stunt_bblock_sml2`,
		`stt_prop_stunt_bblock_sml3`,
		`stt_prop_stunt_bblock_xl1`,
		`stt_prop_stunt_bblock_xl2`,
		`stt_prop_stunt_bblock_xl3`,
		`stt_prop_stunt_bowling_ball`,
		`stt_prop_stunt_bowling_ball`,
		`stt_prop_stunt_bowling_pin`,
		`stt_prop_stunt_bowling_pin`,
		`stt_prop_stunt_bowlpin_stand`,
		`stt_prop_stunt_domino`,
		`stt_prop_stunt_domino`,
		`stt_prop_stunt_jump15`,
		`stt_prop_stunt_jump15`,
		`stt_prop_stunt_jump30`,
		`stt_prop_stunt_jump30`,
		`stt_prop_stunt_jump45`,
		`stt_prop_stunt_jump45`,
		`stt_prop_stunt_jump_l`,
		`stt_prop_stunt_jump_l`,
		`stt_prop_stunt_jump_lb`,
		`stt_prop_stunt_jump_lb`,
		`stt_prop_stunt_jump_loop`,
		`stt_prop_stunt_jump_loop`,
		`stt_prop_stunt_jump_m`,
		`stt_prop_stunt_jump_m`,
		`stt_prop_stunt_jump_mb`,
		`stt_prop_stunt_jump_mb`,
		`stt_prop_stunt_jump_s`,
		`stt_prop_stunt_jump_s`,
		`stt_prop_stunt_jump_sb`,
		`stt_prop_stunt_jump_sb`,
		`stt_prop_stunt_landing_zone_01`,
		`stt_prop_stunt_landing_zone_01`,
		`stt_prop_stunt_ramp`,
		`stt_prop_stunt_ramp`,
		`stt_prop_stunt_small`,
		`stt_prop_stunt_soccer_ball`,
		`stt_prop_stunt_soccer_ball`,
		`stt_prop_stunt_soccer_goal`,
		`stt_prop_stunt_soccer_goal`,
		`stt_prop_stunt_soccer_lball`,
		`stt_prop_stunt_soccer_lball`,
		`stt_prop_stunt_soccer_sball`,
		`stt_prop_stunt_soccer_sball`,
		`stt_prop_stunt_target`,
		`stt_prop_stunt_target`,
		`stt_prop_stunt_target_small`,
		`stt_prop_stunt_track_bumps`,
		`stt_prop_stunt_track_cutout`,
		`stt_prop_stunt_track_dwlink`,
		`stt_prop_stunt_track_dwlink_02`,
		`stt_prop_stunt_track_dwsh15`,
		`stt_prop_stunt_track_dwshort`,
		`stt_prop_stunt_track_dwslope15`,
		`stt_prop_stunt_track_dwslope30`,
		`stt_prop_stunt_track_dwslope45`,
		`stt_prop_stunt_track_dwslope45`,
		`stt_prop_stunt_track_dwturn`,
		`stt_prop_stunt_track_dwuturn`,
		`stt_prop_stunt_track_dwuturn`,
		`stt_prop_stunt_track_exshort`,
		`stt_prop_stunt_track_fork`,
		`stt_prop_stunt_track_funlng`,
		`stt_prop_stunt_track_funlng`,
		`stt_prop_stunt_track_funnel`,
		`stt_prop_stunt_track_hill2`,
		`stt_prop_stunt_track_hill`,
		`stt_prop_stunt_track_jump`,
		`stt_prop_stunt_track_link`,
		`stt_prop_stunt_track_otake`,
		`stt_prop_stunt_track_sh15`,
		`stt_prop_stunt_track_sh30`,
		`stt_prop_stunt_track_sh45`,
		`stt_prop_stunt_track_sh45_a`,
		`stt_prop_stunt_track_short`,
		`stt_prop_stunt_track_short`,
		`stt_prop_stunt_track_slope15`,
		`stt_prop_stunt_track_slope15`,
		`stt_prop_stunt_track_slope30`,
		`stt_prop_stunt_track_slope30`,
		`stt_prop_stunt_track_slope45`,
		`stt_prop_stunt_track_slope45`,
		`stt_prop_stunt_track_st_01`,
		`stt_prop_stunt_track_st_02`,
		`stt_prop_stunt_track_start`,
		`stt_prop_stunt_track_start`,
		`stt_prop_stunt_track_start_02`,
		`stt_prop_stunt_track_straight`,
		`stt_prop_stunt_track_straightice`,
		`stt_prop_stunt_track_turn`,
		`stt_prop_stunt_track_turnice`,
		`stt_prop_stunt_track_uturn`,
		`stt_prop_stunt_tube_crn2`,
		`stt_prop_stunt_tube_crn`,
		`stt_prop_stunt_tube_crn_5d`,
		`stt_prop_stunt_tube_crn_15d`,
		`stt_prop_stunt_tube_crn_30d`,
		`stt_prop_stunt_tube_cross`,
		`stt_prop_stunt_tube_end`,
		`stt_prop_stunt_tube_ent`,
		`stt_prop_stunt_tube_fork`,
		`stt_prop_stunt_tube_gap_01`,
		`stt_prop_stunt_tube_gap_02`,
		`stt_prop_stunt_tube_gap_03`,
		`stt_prop_stunt_tube_hg`,
		`stt_prop_stunt_tube_jmp2`,
		`stt_prop_stunt_tube_jmp`,
		`stt_prop_stunt_tube_l`,
		`stt_prop_stunt_tube_m`,
		`stt_prop_stunt_tube_qg`,
		`stt_prop_stunt_tube_s`,
		`stt_prop_stunt_tube_speed`,
		`stt_prop_stunt_tube_speeda`,
		`stt_prop_stunt_tube_speedb`,
		`stt_prop_stunt_tube_xs`,
		`stt_prop_stunt_tube_xxs`,
		`stt_prop_stunt_wideramp`,
		`stt_prop_track_bend2_bar_l`,
		`stt_prop_track_bend2_bar_l_b`,
		`stt_prop_track_bend2_l`,
		`stt_prop_track_bend2_l_b`,
		`stt_prop_track_bend_5d`,
		`stt_prop_track_bend_5d_bar`,
		`stt_prop_track_bend_15d`,
		`stt_prop_track_bend_15d_bar`,
		`stt_prop_track_bend_30d`,
		`stt_prop_track_bend_30d_bar`,
		`stt_prop_track_bend_180d`,
		`stt_prop_track_bend_180d_bar`,
		`stt_prop_track_bend_bar_l`,
		`stt_prop_track_bend_bar_l_b`,
		`stt_prop_track_bend_bar_m`,
		`stt_prop_track_bend_l`,
		`stt_prop_track_bend_l_b`,
		`stt_prop_track_bend_m`,
		`stt_prop_track_block_01`,
		`stt_prop_track_block_02`,
		`stt_prop_track_block_03`,
		`stt_prop_track_chicane_l`,
		`stt_prop_track_chicane_l_02`,
		`stt_prop_track_chicane_r`,
		`stt_prop_track_chicane_r_02`,
		`stt_prop_track_cross`,
		`stt_prop_track_cross_bar`,
		`stt_prop_track_fork`,
		`stt_prop_track_fork_bar`,
		`stt_prop_track_funnel`,
		`stt_prop_track_funnel_ads_01a`,
		`stt_prop_track_funnel_ads_01b`,
		`stt_prop_track_funnel_ads_01c`,
		`stt_prop_track_jump_01a`,
		`stt_prop_track_jump_01b`,
		`stt_prop_track_jump_01c`,
		`stt_prop_track_jump_02a`,
		`stt_prop_track_jump_02b`,
		`stt_prop_track_jump_02c`,
		`stt_prop_track_link`,
		`stt_prop_track_slowdown`,
		`stt_prop_track_slowdown_t1`,
		`stt_prop_track_slowdown_t2`,
		`stt_prop_track_speedup`,
		`stt_prop_track_speedup_t1`,
		`stt_prop_track_speedup_t2`,
		`stt_prop_track_start`,
		`stt_prop_track_start_02`,
		`stt_prop_track_stop_sign`,
		`stt_prop_track_straight_bar_l`,
		`stt_prop_track_straight_bar_m`,
		`stt_prop_track_straight_bar_s`,
		`stt_prop_track_straight_l`,
		`stt_prop_track_straight_lm`,
		`stt_prop_track_straight_lm_bar`,
		`stt_prop_track_straight_m`,
		`stt_prop_track_straight_s`,
		`stt_prop_track_tube_01`,
		`stt_prop_track_tube_02`,
		`stt_prop_tyre_wall_0l010`,
		`stt_prop_tyre_wall_0l012`,
		`stt_prop_tyre_wall_0l013`,
		`stt_prop_tyre_wall_0l014`,
		`stt_prop_tyre_wall_0l015`,
		`stt_prop_tyre_wall_0l018`,
		`stt_prop_tyre_wall_0l019`,
		`stt_prop_tyre_wall_0l020`,
		`stt_prop_tyre_wall_0l04`,
		`stt_prop_tyre_wall_0l05`,
		`stt_prop_tyre_wall_0l06`,
		`stt_prop_tyre_wall_0l07`,
		`stt_prop_tyre_wall_0l08`,
		`stt_prop_tyre_wall_0l1`,
		`stt_prop_tyre_wall_0l2`,
		`stt_prop_tyre_wall_0l3`,
		`stt_prop_tyre_wall_0l16`,
		`stt_prop_tyre_wall_0l17`,
		`stt_prop_tyre_wall_0r010`,
		`stt_prop_tyre_wall_0r011`,
		`stt_prop_tyre_wall_0r012`,
		`stt_prop_tyre_wall_0r013`,
		`stt_prop_tyre_wall_0r014`,
		`stt_prop_tyre_wall_0r015`,
		`stt_prop_tyre_wall_0r016`,
		`stt_prop_tyre_wall_0r017`,
		`stt_prop_tyre_wall_0r018`,
		`stt_prop_tyre_wall_0r019`,
		`stt_prop_tyre_wall_0r04`,
		`stt_prop_tyre_wall_0r05`,
		`stt_prop_tyre_wall_0r06`,
		`stt_prop_tyre_wall_0r07`,
		`stt_prop_tyre_wall_0r08`,
		`stt_prop_tyre_wall_0r09`,
		`stt_prop_tyre_wall_0r1`,
		`stt_prop_tyre_wall_0r2`,
		`stt_prop_tyre_wall_0r3`,
		`stt_prop_tyre_wall_01`,
		`stt_prop_tyre_wall_010`,
		`stt_prop_tyre_wall_011`,
		`stt_prop_tyre_wall_012`,
		`stt_prop_tyre_wall_013`,
		`stt_prop_tyre_wall_014`,
		`stt_prop_tyre_wall_015`,
		`stt_prop_tyre_wall_02`,
		`stt_prop_tyre_wall_03`,
		`stt_prop_tyre_wall_04`,
		`stt_prop_tyre_wall_05`,
		`stt_prop_tyre_wall_06`,
		`stt_prop_tyre_wall_07`,
		`stt_prop_tyre_wall_08`,
		`stt_prop_tyre_wall_09`,
		`stt_prop_wallride_01`,
		`stt_prop_wallride_01b`,
		`stt_prop_wallride_02`,
		`stt_prop_wallride_02b`,
		`stt_prop_wallride_04`,
		`stt_prop_wallride_05`,
		`stt_prop_wallride_05b`,
		`stt_prop_wallride_45l`,
		`stt_prop_wallride_45la`,
		`stt_prop_wallride_45r`,
		`stt_prop_wallride_45ra`,
		`stt_prop_wallride_90l`,
		`stt_prop_wallride_90lb`,
		`stt_prop_wallride_90r`,
		`stt_prop_wallride_90rb`,
		`test_prop_gravestones_01a`,
		`test_prop_gravestones_02a`,
		`test_prop_gravestones_04a`,
		`test_prop_gravestones_05a`,
		`test_prop_gravestones_07a`,
		`test_prop_gravestones_08a`,
		`test_prop_gravestones_09a`,
		`u_m_y_babyd`,
		`U_M_Y_Zombie_01`,
		`v_44_planeticket`,
		`v_ilev_bk_vaultdoor`,
		`v_ilev_found_cranebucket`,
		`v_res_fa_stones01`,
		`v_res_mexball`,
		`xm_prop_x17_shamal_crash`,
		`xm_prop_x17_sub`,
		`xs_prop_hamburgher_wl`,
		`xs_prop_plastic_bottle_wl`,
	},
}]]

local forbiddenNames = {
	"richrp.pl",
	"richrp",
	"adrenalinarp.pl",
	"adrenalinarp",
	"asgard.",
	"asgard",
	"eulen.",
	"eulen",
	"skript.gg",
	"skript",
	"kosmici",
	"kosmici.space",
	"nigga",
	"n igga",
	"nig ga",
	"nigg a",
	"n igger",
	"ni gger",
	"nig ger",
	"nigge r",
	"pedal",
	"pedał",
	"pedała",
	"pedale",
	"simp",
	"down",
	"faggot",
	"upośledzony",
	"upośledzona",
	"retarded",
	"czarnuch",
	"c wel",
	"cw el",
	"cwel",
	"cwe l",
	"czarnuh",
	"żyd",
	"zyd",
	"hitler",
	"jebac disa",
	"nygus",
	"ciota",
	"cioty",
	"cioto",
	"cwelu",
	"cwele",
	"czarnuchu",
	"niggerze",
	"nigerze",
	"downie",
	"nygusie",
	"karzeł",
	"karzel",
	"simpie",
	"pedalskie",
	"zydzie",
	"żydzie",
	"geju"
}

AddEventHandler("playerConnecting", function(playerName, setKickReason)
	for name in pairs(forbiddenNames) do
		if(string.gsub(string.gsub(string.gsub(string.gsub(playerName:lower(), "-", ""), ",", ""), "%.", ""), " ", ""):find(forbiddenNames[name])) then
			setKickReason("\n[csskrouble AC] Twój nick jest niedozwolony, aby zagrać na serwerze zmień nick na poprawny!")
			CancelEvent()
			print("^3[csskroubleAC] "..playerName.."^7 was kicked for blacklisted name "..forbiddenNames[name])
			break
		end
	end
end)
--[[
AddEventHandler("entityCreating", function(entity)
	local model = GetEntityModel(entity)
	local blacklistedObject = false
	for i,v in pairs(entities.Objects) do 
		if v == model then
			blacklistedObject = true
			break
		end
	end
    if blacklistedObject or entities.Vehicles[GetEntityModel(entity)] then
        CancelEvent()
    end
end)]]

--[[local tazedata = {}
local isSpamTaze = false
AddEventHandler(`weaponDamageEvent`, function (sender, data)
	if data.weaponType == 911657153 or data.weaponType == 1171102963 then
		local src = source
		if tazedata[src] == nil then
				tazedata[src] {
					count = 1,
					time = os.time()
				}
		else
			tazedata[src].count = tazedata[src].count + 1
		end
		if tazedata[src] then
			if tazedata[src].count > 10 then
				local distime = os.time() - tazedata[src].time
				if distime >= 10 then
					tazedata[src].count = 1
				else
					isSpamTaze = true
				end
				if isSpamTaze then
					CancelEvent()
					TriggerEvent(`csskrouble:banPlr`, "nigger", src, "Detection: Tazed players "..tazedata[src].count.." times in 10 seconds")
				end
			end
		end
	end
end)
]]
AddEventHandler("playerDropped", function()
	local src = source
  	payCheckStrikes[src] = nil
end)