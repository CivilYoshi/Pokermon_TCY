-- Miltank 241
-- Blissey 242
local blissey={
  name = "blissey", 
  pos = {x = 0, y = 9}, 
  config = {extra = {limit = 2, triggers = 0}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = G.P_CENTERS.m_lucky
    if not center.edition or (center.edition and not center.edition.polychrome) then
      info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
    end
    return {vars = {center.ability.extra.limit, center.ability.extra.triggers}}
  end,
  rarity = "poke_safari", 
  cost = 10,
  ptype = "Colorless",
  enhancement_gate = 'm_lucky',
  stage = "Two", 
  atlas = "Pokedex2",
  blueprint_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card.lucky_trigger and card.ability.extra.triggers < card.ability.extra.limit then
      G.playing_card = (G.playing_card and G.playing_card + 1) or 1
      local card_to_copy = context.other_card
      local copy = copy_card(card_to_copy, nil, nil, G.playing_card)
      copy:add_to_deck()
      G.deck.config.card_limit = G.deck.config.card_limit + 1
      table.insert(G.playing_cards, copy)
      G.hand:emplace(copy)
      copy.states.visible = nil

      G.E_MANAGER:add_event(Event({
          func = function()
              copy:start_materialize()
              local edition = {polychrome = true}
              copy:set_edition(edition, true)
              playing_card_joker_effects({copy})
              return true
          end
      })) 
      card.ability.extra.triggers = card.ability.extra.triggers + 1
      return {
          message = localize('k_copied_ex'),
          colour = G.C.CHIPS,
          card = card,
          playing_cards_created = {true}
      }
    end
    if not context.repetition and not context.individual and context.end_of_round then
      card.ability.extra.triggers = 0
    end
  end
}
-- Raikou 243
-- Entei 244
-- Suicune 245
-- Larvitar 246
-- Pupitar 247
-- Tyranitar 248
-- Lugia 249
local lugia = {
  name = "lugia",
  pos = {x = 0, y = 10},
  soul_pos = { x = 1, y = 10},
  config = {extra = {
    Xmult = 1.0,
	Xmult_mod = 4,
    energy_removed = 0,
    energy_threshold = 3
  }},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    -- Calculate current X multiplier based on removed energy
    local current_mult = 1 + math.floor(center.ability.extra.energy_removed / center.ability.extra.energy_threshold) * center.ability.extra.Xmult_mod
    return {vars = {
      center.ability.extra.energy_threshold,
      center.ability.extra.energy_removed,
      current_mult
    }}
  end,
  rarity = 4, -- Legendary
  cost = 20,
  stage = "Legendary",
  ptype = "Psychic",
  atlas = "Pokedex2", 
  blueprint_compat = true,
  calculate = function(self, card, context)
    -- Check if a blind is being selected (transitions to shop round)
    if context.setting_blind and not context.blueprint then
      local energy_removed = 0
      local affected_types = {"Fire", "Lightning", "Water"}
      
      -- Look for jokers with these types
      for _, joker_type in ipairs(affected_types) do
        local type_jokers = find_pokemon_type(joker_type)
        
        -- Take energy from leftmost of each type
        for _, target_joker in ipairs(type_jokers) do
          if target_joker ~= card and 
             target_joker.ability.extra and 
             (target_joker.ability.extra.energy_count or 0) + (target_joker.ability.extra.c_energy_count or 0) > 0 then
            
            -- Store the current energy counts before decreasing
            local prev_energy_count = target_joker.ability.extra.energy_count or 0
            local prev_c_energy_count = target_joker.ability.extra.c_energy_count or 0
            
            -- Determine if we're removing a colorless energy or a type energy
            local removing_colorless = prev_c_energy_count > 0
            
            -- Standard scaling properties affected by energy
            local scale_props = energy_whitelist
            
            -- Store current values before modification
            local old_values = {}
            for _, prop in ipairs(scale_props) do
              if target_joker.ability.extra[prop] then
                old_values[prop] = target_joker.ability.extra[prop]
              end
            end
            
            -- Decrease the appropriate energy counter
            if removing_colorless then
              target_joker.ability.extra.c_energy_count = prev_c_energy_count - 1
            else
              target_joker.ability.extra.energy_count = prev_energy_count - 1
            end
            
            -- Recalculate the stats based on the new energy
            for _, prop in ipairs(scale_props) do
              if target_joker.ability.extra[prop] and target_joker.config.center.config.extra[prop] then
                -- Get the base value from the center config
                local base_value = target_joker.config.center.config.extra[prop]
                
                -- Calculate the energy contribution that's being removed
                local energy_contribution = 0 
				local energy_mod_value = energy_values[prop]
                
                if removing_colorless then
                    energy_contribution = (base_value * 0.5) * (target_joker.ability.extra.escale or 1) * energy_mod_value
                  else
                    energy_contribution = base_value * (target_joker.ability.extra.escale or 1) * energy_mod_value
                end
                
				-- Subtract the energy contribution from the current value
                target_joker.ability.extra[prop] = target_joker.ability.extra[prop] - energy_contribution
                
                -- Update money_frac for proper display if it exists
                if target_joker.ability[prop.."_frac"] then
                  local new_frac = 0
                  if prev_energy_count > 1 then
                    new_frac = (prev_energy_count - 1) / prev_energy_count * target_joker.ability[prop.."_frac"]
                  end
                  target_joker.ability[prop.."_frac"] = new_frac
                end
              end
            end
            
            energy_removed = energy_removed + 1
            card_eval_status_text(target_joker, 'extra', nil, nil, nil, 
              {message = localize("poke_energy_drain"), colour = G.C.RED})
            break -- Take from only the first one of each type
          end
        end
      end
      
      if energy_removed > 0 then
        card.ability.extra.energy_removed = card.ability.extra.energy_removed + energy_removed
        card_eval_status_text(card, 'extra', nil, nil, nil, 
          {message = localize("poke_energy_absorb"), colour = G.C.BLUE})
        card:juice_up(0.8, 0.5)
      end
    end
    
    -- Apply multiplier when scoring
    if context.cardarea == G.jokers and context.scoring_hand then
      if context.joker_main then
        local current_mult = 1 + math.floor(card.ability.extra.energy_removed / card.ability.extra.energy_threshold) * card.ability.extra.Xmult_mod
        
        if current_mult > 1 then
          return {
            message = localize{type = 'variable', key = 'a_xmult', vars = {current_mult}},
            colour = G.C.XMULT,
            Xmult_mod = current_mult
          }
        end
      end
    end
  end
}
-- Ho-oh 250
local hooh = {
    name = "hooh",
    pos = {x = 2, y = 10}, 
    soul_pos = { x = 3, y = 10},
    config = {extra = {Xmult = 1.0}},
    loc_vars = function(self, info_queue, center)
        type_tooltip(self, info_queue, center)
        info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
        return {vars = {center.ability.extra.Xmult + (0.1 * (center.ability.extra.energy_count or 0))}}
    end,
    rarity = 4,
    cost = 20,
    stage = "Legendary",
    ptype = "Fire",
    atlas = "Pokedex2",
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.scoring_hand then
            if context.before and not context.blueprint and G.GAME.current_round.hands_played == 0 then
                local suits = {Hearts = false, Spades = false, Clubs = false, Diamonds = false}
                for _, played_card in ipairs(context.scoring_hand) do
                    if played_card:is_suit("Hearts") then suits.Hearts = true end
                    if played_card:is_suit("Spades") then suits.Spades = true end
                    if played_card:is_suit("Clubs") then suits.Clubs = true end
                    if played_card:is_suit("Diamonds") then suits.Diamonds = true end
                end
                
                if suits.Hearts and suits.Spades and suits.Clubs and suits.Diamonds then
                    local leftmost = context.scoring_hand[1]
                    local edition = {polychrome = true}
                    leftmost:set_edition(edition, true)
                    if not leftmost.seal then
                        local args = {guaranteed = true}
                        local seal_type = SMODS.poll_seal(args)
                        leftmost:set_seal(seal_type, true)
                    end
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            leftmost:juice_up()
                            return true
                        end
                    }))
                end
            end

            if context.joker_main then
                local polychrome_count = 0
                for _, played_card in ipairs(context.scoring_hand) do
                    if played_card.edition and played_card.edition.polychrome then
                        polychrome_count = polychrome_count + 1
                    end
                end
                
                if polychrome_count > 0 then
                    local base_mult = card.ability.extra.Xmult
                    if card.ability.extra and card.ability.extra.energy_count then
                        base_mult = base_mult + (0.1 * card.ability.extra.energy_count)
                    end

                    return {
                        message = localize('poke_sacred_fire_ex'),
                        colour = G.C.XMULT,
                        Xmult_mod = 1 + (base_mult * polychrome_count)
                    }
                end
            end
        end
    end
}
-- Celebi 251
-- Treecko 252
local treecko={
  name = "treecko",
  pos = {x = 0, y = 0},
  config = {extra = {money_mod = 1, money_earned = 0, targets = {{value = "Ace", id = "14"}, {value = "King", id = "13"}, {value = "Queen", id = "12"}}, h_size = 1, odds = 2}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = {set = 'Other', key = 'nature', vars = {"ranks"}}
    local card_vars = {center.ability.extra.money_mod, center.ability.extra.money_earned, center.ability.extra.h_size, ''..(G.GAME and G.GAME.probabilities.normal or 1), center.ability.extra.odds}
    add_target_cards_to_vars(card_vars, center.ability.extra.targets)
    return {vars = card_vars}
  end,
  rarity = 2,
  cost = 5,
  stage = "Basic",
  ptype = "Grass",
  atlas = "Pokedex3",
  perishable_compat = false,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    if context.individual and not context.end_of_round and context.cardarea == G.play and not context.other_card.debuff then
      local earn = false
      if find_other_poke_or_energy_type(card, "Grass") > 0 then
        earn = true
      end
      if (pseudorandom('treecko') < G.GAME.probabilities.normal/card.ability.extra.odds) or earn then
        for i=1, #card.ability.extra.targets do
          if context.other_card:get_id() == card.ability.extra.targets[i].id then
              local earned = ease_poke_dollars(card, "grovyle", card.ability.extra.money_mod, true)
              card.ability.extra.money_earned = card.ability.extra.money_earned + earned
              return {
                dollars = earned,
                card = card
              }
          end
        end
      end
    end
    return scaling_evo(self, card, context, "j_poke_grovyle", card.ability.extra.money_earned, 16)
  end,
  add_to_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.hand:change_size(card.ability.extra.h_size)
    end
  end,
  remove_from_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.hand:change_size(-card.ability.extra.h_size)
    end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    if initial then
      card.ability.extra.targets = get_poke_target_card_ranks("treecko", 3, card.ability.extra.targets)
    end
  end
}
-- Grovyle 253
local grovyle={
  name = "grovyle",
  pos = {x = 1, y = 0},
  config = {extra = {money_mod = 2, money_earned = 0, targets = {{value = "Ace", id = "14"}, {value = "King", id = "13"}, {value = "Queen", id = "12"}}, h_size = 1, odds = 2}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = {set = 'Other', key = 'nature', vars = {"ranks"}}
    local card_vars = {center.ability.extra.money_mod, center.ability.extra.money_earned, center.ability.extra.h_size, ''..(G.GAME and G.GAME.probabilities.normal or 1), center.ability.extra.odds}
    add_target_cards_to_vars(card_vars, center.ability.extra.targets)
    return {vars = card_vars}
  end,
  rarity = "poke_safari",
  cost = 8,
  stage = "One",
  ptype = "Grass",
  atlas = "Pokedex3",
  perishable_compat = false,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    if context.individual and not context.end_of_round and context.cardarea == G.play and not context.other_card.debuff then
      local earn = false
      if find_other_poke_or_energy_type(card, "Grass") > 0 then
        earn = true
      end
      if (pseudorandom('treecko') < G.GAME.probabilities.normal/card.ability.extra.odds) or earn then
        for i=1, #card.ability.extra.targets do
          if context.other_card:get_id() == card.ability.extra.targets[i].id then
              local earned = ease_poke_dollars(card, "grovyle", card.ability.extra.money_mod, true)
              card.ability.extra.money_earned = card.ability.extra.money_earned + earned
              return {
                dollars = earned,
                card = card
              }
          end
        end
      end
    end
    return scaling_evo(self, card, context, "j_poke_sceptile", card.ability.extra.money_earned, 32)
  end,
  add_to_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.hand:change_size(card.ability.extra.h_size)
    end
  end,
  remove_from_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.hand:change_size(-card.ability.extra.h_size)
    end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    if initial then
      card.ability.extra.targets = get_poke_target_card_ranks("grovyle", 3, card.ability.extra.targets)
    end
  end
}
-- Sceptile 254
local sceptile={
  name = "sceptile",
  pos = {x = 2, y = 0},
  config = {extra = {money_mod = 2, money_earned = 0, targets = {{value = "Ace", id = "14"}, {value = "King", id = "13"}, {value = "Queen", id = "12"}}, h_size = 1, odds = 2}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = {set = 'Other', key = 'nature', vars = {"ranks"}}
    local card_vars = {center.ability.extra.money_mod, center.ability.extra.money_earned, center.ability.extra.h_size, 
                       math.min(14, find_other_poke_or_energy_type(center, "Grass") * center.ability.extra.money_mod)}
    add_target_cards_to_vars(card_vars, center.ability.extra.targets)
    return {vars = card_vars}
  end,
  rarity = "poke_safari",
  cost = 10,
  stage = "Two",
  ptype = "Grass",
  atlas = "Pokedex3",
  perishable_compat = false,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    if context.individual and not context.end_of_round and context.cardarea == G.play and not context.other_card.debuff then
      for i=1, #card.ability.extra.targets do
        if context.other_card:get_id() == card.ability.extra.targets[i].id then
            local earned = ease_poke_dollars(card, "sceptile", card.ability.extra.money_mod, true)
            card.ability.extra.money_earned = card.ability.extra.money_earned + earned
            return {
              dollars = earned,
              card = card
            }
        end
      end
    end
  end,
  calc_dollar_bonus = function(self, card)
    return ease_poke_dollars(card, "sceptile", math.min(14, find_other_poke_or_energy_type(card, "Grass") * card.ability.extra.money_mod), true) 
	end,
  add_to_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.hand:change_size(card.ability.extra.h_size)
    end
  end,
  remove_from_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.hand:change_size(-card.ability.extra.h_size)
    end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    if initial then
      card.ability.extra.targets = get_poke_target_card_ranks("sceptile", 3, card.ability.extra.targets)
    end
  end
}
-- Torchic 255
local torchic={
  name = "torchic",
  pos = {x = 3, y = 0},
  config = {extra = {mult = 1, cards_discarded = 0, mult_earned = 0, targets = {{value = "Ace", id = "14"}, {value = "King", id = "13"}, {value = "Queen", id = "12"}}, d_size = 1}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = {set = 'Other', key = 'nature', vars = {"ranks"}}
    local card_vars = {center.ability.extra.mult, center.ability.extra.mult_earned, center.ability.extra.d_size, center.ability.extra.mult * center.ability.extra.cards_discarded}
    add_target_cards_to_vars(card_vars, center.ability.extra.targets)
    return {vars = card_vars}
  end,
  rarity = 2,
  cost = 5,
  stage = "Basic",
  ptype = "Fire",
  atlas = "Pokedex3",
  perishable_compat = false,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.scoring_hand then
      if context.joker_main then
        local mult = card.ability.extra.mult * card.ability.extra.cards_discarded 
        card.ability.extra.mult_earned = card.ability.extra.mult_earned + mult
        return {
          message = localize{type = 'variable', key = 'a_mult', vars = {mult}}, 
          colour = G.C.MULT,
          mult_mod = mult
        }
      end
    end
    if context.discard and not context.other_card.debuff then
      for i=1, #card.ability.extra.targets do
        if context.other_card:get_id() == card.ability.extra.targets[i].id then
          local discard_plus = 1
          if find_other_poke_or_energy_type(card, "Fire") > 0 or find_other_poke_or_energy_type(card, "Fighting") > 0 then
            discard_plus = 2
          end 
          card.ability.extra.cards_discarded = card.ability.extra.cards_discarded + discard_plus
          return {
            message = localize{type='variable',key='a_mult',vars={discard_plus}},
            colour = G.C.RED,
            delay = 0.45, 
            card = card
          }
        end
      end
    end
    if context.end_of_round and not context.individual and not context.repetition then
      card.ability.extra.cards_discarded = 0
      card:juice_up()
      card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_reset')})
    end
    return scaling_evo(self, card, context, "j_poke_combusken", card.ability.extra.mult_earned, 60)
  end,
  add_to_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.d_size
      ease_discard(card.ability.extra.d_size)
    end
  end,
  remove_from_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.d_size
      ease_discard(-card.ability.extra.d_size)
    end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    if initial then
      card.ability.extra.targets = get_poke_target_card_ranks("torchic", 3, card.ability.extra.targets)
    end
  end
}
-- Combusken 256
local combusken={
  name = "combusken",
  pos = {x = 4, y = 0},
  config = {extra = {mult = 3, cards_discarded = 0, mult_earned = 0, targets = {{value = "Ace", id = "14"}, {value = "King", id = "13"}, {value = "Queen", id = "12"}}, d_size = 1}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = {set = 'Other', key = 'nature', vars = {"ranks"}}
    local card_vars = {center.ability.extra.mult, center.ability.extra.mult_earned, center.ability.extra.d_size, center.ability.extra.mult * center.ability.extra.cards_discarded}
    add_target_cards_to_vars(card_vars, center.ability.extra.targets)
    return {vars = card_vars}
  end,
  rarity = "poke_safari",
  cost = 8,
  stage = "One",
  ptype = "Fire",
  atlas = "Pokedex3",
  perishable_compat = false,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.scoring_hand then
      if context.joker_main then
        local mult = card.ability.extra.mult * card.ability.extra.cards_discarded 
        card.ability.extra.mult_earned = card.ability.extra.mult_earned + mult
        return {
          message = localize{type = 'variable', key = 'a_mult', vars = {mult}}, 
          colour = G.C.MULT,
          mult_mod = mult
        }
      end
    end
    if context.discard and not context.other_card.debuff then
      for i=1, #card.ability.extra.targets do
        if context.other_card:get_id() == card.ability.extra.targets[i].id then
          local discard_plus = 1
          if find_other_poke_or_energy_type(card, "Fire") > 0 or find_other_poke_or_energy_type(card, "Fighting") > 0 then
            discard_plus = 2
          end 
          card.ability.extra.cards_discarded = card.ability.extra.cards_discarded + discard_plus
          return {
            message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult}},
            colour = G.C.RED,
            delay = 0.45, 
            card = card
          }
        end
      end
    end
    if context.end_of_round and not context.individual and not context.repetition then
      card.ability.extra.cards_discarded = 0
      card:juice_up()
      card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_reset')})
    end
    return scaling_evo(self, card, context, "j_poke_blaziken", card.ability.extra.mult_earned, 150)
  end,
  add_to_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.d_size
      ease_discard(card.ability.extra.d_size)
    end
  end,
  remove_from_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.d_size
      ease_discard(-card.ability.extra.d_size)
    end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    if initial then
      card.ability.extra.targets = get_poke_target_card_ranks("combusken", 3, card.ability.extra.targets)
    end
  end
}
-- Blaziken 257
local blaziken={
  name = "blaziken",
  pos = {x = 5, y = 0},
  config = {extra = {Xmult = .15, mult = 1, cards_discarded = 0, targets = {{value = "Ace", id = "14"}, {value = "King", id = "13"}, {value = "Queen", id = "12"}}, d_size = 1}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = {set = 'Other', key = 'nature', vars = {"ranks"}}
    local card = center
    local mult = card.ability.extra.mult * card.ability.extra.cards_discarded * (find_other_poke_or_energy_type(card, "Fire", true) + find_other_poke_or_energy_type(card, "Fighting", true))
    local Xmult = 1 + card.ability.extra.Xmult * card.ability.extra.cards_discarded * (find_other_poke_or_energy_type(card, "Fire", true) + find_other_poke_or_energy_type(card, "Fighting", true))
    local card_vars = {center.ability.extra.Xmult, center.ability.extra.d_size, Xmult, center.ability.extra.mult, mult}
    add_target_cards_to_vars(card_vars, center.ability.extra.targets)
    return {vars = card_vars}
  end,
  rarity = "poke_safari",
  cost = 10,
  stage = "Two",
  ptype = "Fire",
  atlas = "Pokedex3",
  perishable_compat = false,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.scoring_hand then
      if context.joker_main then
        local mult = card.ability.extra.mult * card.ability.extra.cards_discarded * (find_other_poke_or_energy_type(card, "Fire", true) + find_other_poke_or_energy_type(card, "Fighting", true))
        local Xmult = 1 + card.ability.extra.Xmult * card.ability.extra.cards_discarded * (find_other_poke_or_energy_type(card, "Fire", true) + find_other_poke_or_energy_type(card, "Fighting", true))
        return {
          message = localize('poke_blazekick_ex'), 
          colour = G.C.MULT,
          Xmult_mod = Xmult,
          mult_mod = mult
        }
      end
    end
    if context.discard and not context.other_card.debuff then
      for i=1, #card.ability.extra.targets do
        if context.other_card:get_id() == card.ability.extra.targets[i].id then
          card.ability.extra.cards_discarded = card.ability.extra.cards_discarded + 1
          return {
            message = localize('k_upgrade_ex'),
            colour = G.C.RED,
            delay = 0.45, 
            card = card
          }
        end
      end
    end
    if context.end_of_round and not context.individual and not context.repetition then
      card.ability.extra.cards_discarded = 0
      card:juice_up()
      card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_reset')})
    end
  end,
  add_to_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.d_size
      ease_discard(card.ability.extra.d_size)
    end
  end,
  remove_from_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.d_size
      ease_discard(-card.ability.extra.d_size)
    end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    if initial then
      card.ability.extra.targets = get_poke_target_card_ranks("blaziken", 3, card.ability.extra.targets)
    end
  end
}
-- Mudkip 258
local mudkip={
  name = "mudkip",
  pos = {x = 6, y = 0},
  config = {extra = {chips = 20, chips_earned = 0, targets = {{value = "Ace", id = "14"}, {value = "King", id = "13"}, {value = "Queen", id = "12"}}, hands = 1}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = {set = 'Other', key = 'nature', vars = {"ranks"}}
    local card_vars = {center.ability.extra.chips, center.ability.extra.chips_earned, center.ability.extra.hands}
    add_target_cards_to_vars(card_vars, center.ability.extra.targets)
    return {vars = card_vars}
  end,
  rarity = 2,
  cost = 5,
  stage = "Basic",
  ptype = "Water",
  atlas = "Pokedex3",
  perishable_compat = false,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    if context.individual and not context.end_of_round and context.cardarea == G.play and not context.other_card.debuff then
      local chips = card.ability.extra.chips
      if find_other_poke_or_energy_type(card, "Water") > 0 or find_other_poke_or_energy_type(card, "Earth") > 0 then
        chips = chips * 2
      end
      for i=1, #card.ability.extra.targets do
        if context.other_card:get_id() == card.ability.extra.targets[i].id then
          card.ability.extra.chips_earned = card.ability.extra.chips_earned + chips
          return {
            chips = chips,
            card = card
          }
        end
      end
    end
    return scaling_evo(self, card, context, "j_poke_marshtomp", card.ability.extra.chips_earned, 400)
  end,
  add_to_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hands
      ease_hands_played(card.ability.extra.hands)
    end
  end,
  remove_from_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hands
      ease_hands_played(-card.ability.extra.hands)
    end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    if initial then
      card.ability.extra.targets = get_poke_target_card_ranks("mudkip", 3, card.ability.extra.targets)
    end
  end
}
-- Marshtomp 259
local marshtomp={
  name = "marshtomp",
  pos = {x = 7, y = 0},
  config = {extra = {chips = 30, chips_earned = 0, targets = {{value = "Ace", id = "14"}, {value = "King", id = "13"}, {value = "Queen", id = "12"}}, hands = 1}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = {set = 'Other', key = 'nature', vars = {"ranks"}}
    local card_vars = {center.ability.extra.chips, center.ability.extra.chips_earned, center.ability.extra.hands}
    add_target_cards_to_vars(card_vars, center.ability.extra.targets)
    return {vars = card_vars}
  end,
  rarity = "poke_safari",
  cost = 8,
  stage = "One",
  ptype = "Water",
  atlas = "Pokedex3",
  perishable_compat = false,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    if context.individual and not context.end_of_round and context.cardarea == G.play and not context.other_card.debuff then
      local chips = card.ability.extra.chips
      if find_other_poke_or_energy_type(card, "Water") > 0 or find_other_poke_or_energy_type(card, "Earth") > 0 then
        chips = chips * 2
      end
      for i=1, #card.ability.extra.targets do
        if context.other_card:get_id() == card.ability.extra.targets[i].id then
          card.ability.extra.chips_earned = card.ability.extra.chips_earned + chips
          return {
            chips = chips,
            card = card
          }
        end
      end
    end
    return scaling_evo(self, card, context, "j_poke_swampert", card.ability.extra.chips_earned, 960)
  end,
  add_to_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hands
      ease_hands_played(card.ability.extra.hands)
    end
  end,
  remove_from_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hands
      ease_hands_played(-card.ability.extra.hands)
    end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    if initial then
      card.ability.extra.targets = get_poke_target_card_ranks("marshtomp", 3, card.ability.extra.targets)
    end
  end
}
-- Swampert 260
local swampert={
  name = "swampert",
  pos = {x = 8, y = 0},
  config = {extra = {chips = 40, chip_mod = 20, chips_earned = 0, targets = {{value = "Ace", id = "14"}, {value = "King", id = "13"}, {value = "Queen", id = "12"}}, hands = 1}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = {set = 'Other', key = 'nature', vars = {"ranks"}}
    local card_vars = {center.ability.extra.chips, center.ability.extra.chips_earned, center.ability.extra.hands, 
                       center.ability.extra.chips + center.ability.extra.chip_mod * (find_other_poke_or_energy_type(center, "Water") + find_other_poke_or_energy_type(center, "Earth")),                       center.ability.extra.chip_mod}
    add_target_cards_to_vars(card_vars, center.ability.extra.targets)
    return {vars = card_vars}
  end,
  rarity = "poke_safari",
  cost = 10,
  stage = "Two",
  ptype = "Water",
  atlas = "Pokedex3",
  perishable_compat = false,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    if context.individual and not context.end_of_round and context.cardarea == G.play and not context.other_card.debuff then
      local chips = card.ability.extra.chips
      if find_other_poke_or_energy_type(card, "Water") or find_other_poke_or_energy_type(card, "Earth") then
        chips = chips + card.ability.extra.chip_mod * (find_other_poke_or_energy_type(card, "Water") + find_other_poke_or_energy_type(card, "Earth"))
      end
      for i=1, #card.ability.extra.targets do
        if context.other_card:get_id() == card.ability.extra.targets[i].id then
          card.ability.extra.chips_earned = card.ability.extra.chips_earned + chips
          return {
            chips = chips,
            card = card
          }
        end
      end
    end
  end,
  add_to_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hands
      ease_hands_played(card.ability.extra.hands)
    end
  end,
  remove_from_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hands
      ease_hands_played(-card.ability.extra.hands)
    end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    if initial then
      card.ability.extra.targets = get_poke_target_card_ranks("swampert", 3, card.ability.extra.targets)
    end
  end
}
-- Poochyena 261
-- Mightyena 262
-- Zigzagoon 263
-- Linoone 264
-- Wurmple 265
-- Silcoon 266
-- Beautifly 267
-- Cascoon 268
-- Dustox 269
-- Lotad 270
return {name = "Pokemon Jokers 240-270", 
        list = {blissey, lugia, hooh, treecko, grovyle, sceptile, torchic, combusken, blaziken, mudkip, marshtomp, swampert},
}
