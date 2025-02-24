-- Delcatty 301
-- Sableye 302
-- Mawile 303
-- Aron 304
local aron = {
  name = "aron",
  pos = { x = 2, y = 5 },
  config = { extra = { Xmult = 1, Xmult_mod = .25, eaten = 0 } },
  rarity = 2,
  cost = 6,
  stage = "Basic",
  atlas = "Pokedex3",
  ptype = "Metal",
  blueprint_compat = true,
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = G.P_CENTERS.c_chariot
    return { vars = { center.ability.extra.Xmult, center.ability.extra.Xmult_mod, center.ability.extra.eaten } }
  end,
  calculate = function(self, card, context)
    if context.setting_blind and not card.getting_sliced and context.blind == G.P_BLINDS.bl_small then
      if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        local _card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_chariot')
        _card:add_to_deck()
        G.consumeables:emplace(_card)
        card_eval_status_text(_card, 'extra', nil, nil, nil, { message = localize('k_plus_tarot'), colour = G.C.PURPLE })
      end
    elseif context.cardarea == G.jokers and context.before and not context.blueprint then
      for k, v in ipairs(context.scoring_hand) do
        if v.config.center == G.P_CENTERS.m_steel and not v.debuff then
          card.ability.extra.eaten = card.ability.extra.eaten + 1
          card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
          G.E_MANAGER:add_event(Event({
            func = function()
              v:juice_up()
              return true
            end
          }))
        end
      end
    elseif context.cardarea == G.jokers and context.scoring_hand and context.joker_main then
      return {
        message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
        colour = G.C.XMULT,
        Xmult_mod = card.ability.extra.Xmult
      }
    elseif context.destroying_card then
      return not context.blueprint and context.destroying_card.config.center == G.P_CENTERS.m_steel
    end
    return scaling_evo(self, card, context, "j_poke_lairon", card.ability.extra.Xmult, 2)
  end
}
-- Lairon 305
local lairon = {
  name = "lairon",
  pos = { x = 3, y = 5 },
  config = { extra = { Xmult = 1, Xmult_mod = .25, eaten = 0 } },
  rarity = 3,
  cost = 8,
  stage = "One",
  atlas = "Pokedex3",
  ptype = "Metal",
  blueprint_compat = true,
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = G.P_CENTERS.c_chariot
    return { vars = { center.ability.extra.Xmult, center.ability.extra.Xmult_mod, center.ability.extra.eaten } }
  end,
  calculate = function(self, card, context)
    if context.setting_blind and not card.getting_sliced and not context.blind.boss then
      if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        local _card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_chariot')
        _card:add_to_deck()
        G.consumeables:emplace(_card)
        card_eval_status_text(_card, 'extra', nil, nil, nil, { message = localize('k_plus_tarot'), colour = G.C.PURPLE })
      end
    elseif context.cardarea == G.jokers and context.before and not context.blueprint then
      for k, v in ipairs(context.scoring_hand) do
        if v.config.center == G.P_CENTERS.m_steel and not v.debuff then
          card.ability.extra.eaten = card.ability.extra.eaten + 1
          card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
          G.E_MANAGER:add_event(Event({
            func = function()
              v:juice_up()
              return true
            end
          }))
        end
      end
    elseif context.cardarea == G.jokers and context.scoring_hand and context.joker_main then
      return {
        message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
        colour = G.C.XMULT,
        Xmult_mod = card.ability.extra.Xmult
      }
    elseif context.destroying_card then
      return not context.blueprint and context.destroying_card.config.center == G.P_CENTERS.m_steel
    end
    return scaling_evo(self, card, context, "j_poke_aggron", card.ability.extra.Xmult, 4)
  end
}
-- Aggron 306
local aggron = {
  name = "aggron",
  pos = { x = 4, y = 5 },
  config = { extra = { Xmult = 1, Xmult_mod = .25, eaten = 0 } },
  rarity = "poke_safari",
  cost = 12,
  stage = "Two",
  atlas = "Pokedex3",
  ptype = "Metal",
  blueprint_compat = true,
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = G.P_CENTERS.c_chariot
    return { vars = { center.ability.extra.Xmult, center.ability.extra.Xmult_mod, center.ability.extra.eaten } }
  end,
  calculate = function(self, card, context)
    if context.setting_blind and not card.getting_sliced then
      if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        local _card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_chariot')
        _card:add_to_deck()
        G.consumeables:emplace(_card)
        card_eval_status_text(_card, 'extra', nil, nil, nil, { message = localize('k_plus_tarot'), colour = G.C.PURPLE })
      end
    elseif context.cardarea == G.jokers and context.before and not context.blueprint then
      for k, v in ipairs(context.scoring_hand) do
        if v.config.center == G.P_CENTERS.m_steel and not v.debuff then
          card.ability.extra.eaten = card.ability.extra.eaten + 1
          card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_mod
          G.E_MANAGER:add_event(Event({
            func = function()
              v:juice_up()
              return true
            end
          }))
        end
      end
    elseif context.cardarea == G.jokers and context.scoring_hand and context.joker_main then
      return {
        message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
        colour = G.C.XMULT,
        Xmult_mod = card.ability.extra.Xmult
      }
    elseif context.destroying_card then
      return not context.blueprint and context.destroying_card.config.center == G.P_CENTERS.m_steel
    end
  end
}
-- Meditite 307
-- Medicham 308
-- Electrike 309
-- Manectric 310
-- Plusle 311
-- Minun 312
-- Volbeat 313
-- Illumise 314
-- Roselia 315
-- Gulpin 316
-- Swalot 317
-- Carvanha 318
-- Sharpedo 319
-- Wailmer 320
-- Wailord 321
-- Numel 322
-- Camerupt 323
-- Torkoal 324
-- Spoink 325
-- Grumpig 326
-- Spinda 327
-- Trapinch 328
local trapinch={
  name = "trapinch",
  pos = {x = 6, y = 7},
  config = {extra = {
    Xmult = 1.5,
    rounds = 3
  }},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    return {vars = {center.ability.extra.Xmult, center.ability.extra.rounds}}
  end,
  rarity = 1,
  cost = 3,
  stage = "Basic",
  ptype = "Earth",
  atlas = "Pokedex3",
  blueprint_compat = true,
  calculate = function(self, card, context)
    -- Apply automatic diamond selection whenever a new hand is drawn
    if context.hand_drawn and not context.blueprint then
      G.E_MANAGER:add_event(Event({
        func = function()
          for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit("Diamonds") then
              G.hand.cards[i].ability.forced_selection = true
              G.hand:add_to_highlighted(G.hand.cards[i])
            end
          end
          return true
        end
      }))
    end
    
	-- Apply XMult when scoring
    if context.cardarea == G.jokers and context.scoring_hand then
      if context.joker_main then
        return {
          message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.Xmult}},
          colour = G.C.XMULT,
          Xmult_mod = card.ability.extra.Xmult
		  
        }
      end
    end
    
    -- Handle card drawing mid-round (like from Tarot cards)
    if context.drawing_card and not context.blueprint then
      if context.other_card and context.other_card:is_suit("Diamonds") then
        context.other_card.ability.forced_selection = true
        G.hand:add_to_highlighted(context.other_card)
      end
    end
    
    -- Check for evolution
    return level_evo(self, card, context, "j_poke_vibrava")
  end,
  
  load = function(self, card, card_table, other_card)
        G.E_MANAGER:add_event(Event({
        func = function()
          for i = 1, #G.hand.cards do
            if G.hand.cards[i]:is_suit("Diamonds") then
              G.hand.cards[i].ability.forced_selection = true
              G.hand:add_to_highlighted(G.hand.cards[i])
            end
          end
          return true
        end
      }))
	  end,
  
  -- Clean up forced selections when removed
  remove_from_deck = function(self, card, from_debuff)
    for k, v in ipairs(G.playing_cards) do
      v.ability.forced_selection = nil
    end
  end
}
-- Vibrava 329
local vibrava={
  name = "vibrava",
  pos = {x = 7, y = 7},
  config = {extra = {
    mult = 15,
    diamonds_scored = 0
  }},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    return {vars = {center.ability.extra.mult, center.ability.extra.diamonds_scored}}
  end,
  rarity = "poke_safari",
  cost = 6,
  stage = "One",
  ptype = "Earth",
  atlas = "Pokedex3",
  blueprint_compat = true,
  calculate = function(self, card, context)
    -- Apply Mult when scoring
    if context.cardarea == G.jokers and context.scoring_hand then
      if context.joker_main then
        return {
          message = localize{type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult}},
          colour = G.C.MULT,
          mult_mod = card.ability.extra.mult
        }
      end
    end
    
    -- Track diamond cards played
    if context.individual and context.cardarea == G.play and context.other_card:is_suit("Diamonds") and not context.blueprint then
      -- Check if this is the first diamond this round
      if not card.ability.extra.diamond_played_this_round then
        card.ability.extra.diamond_played_this_round = true
        card.ability.extra.diamonds_scored = card.ability.extra.diamonds_scored + 1
        
        -- Grant temporary +1 hand for this round
        G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + 1
        
        return {
          message = localize('k_plus_hand'),
          colour = G.C.BLUE,
          card = card
        }
      else
        -- Just count the diamond
        card.ability.extra.diamonds_scored = card.ability.extra.diamonds_scored + 1
      end
    end
    
    -- Reset diamond tracker at end of round
    if context.end_of_round and not context.individual and not context.repetition then
      card.ability.extra.diamond_played_this_round = false
    end
    
    -- Check for evolution to Flygon based ONLY on diamond count
    return scaling_evo(self, card, context, "j_poke_flygon", card.ability.extra.diamonds_scored, 25)
  end
}
-- Flygon 330
local flygon={
  name = "flygon",
  pos = {x = 8, y = 7},
  config = {extra = {
    Xmult = 1.0,
    Xmult_mod = 0.1,
    diamonds_enhanced = 0,
    enhanced_this_round = false
  }},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    
    -- Count enhanced diamond cards in deck
    local enhanced_diamonds = 0
    if G.playing_cards then
      for _, v in ipairs(G.playing_cards) do
        if v:is_suit("Diamonds") and v.ability.name ~= "Default Base" then
          enhanced_diamonds = enhanced_diamonds + 1
        end
      end
    end
    
    local xmult_total = center.ability.extra.Xmult + (enhanced_diamonds * center.ability.extra.Xmult_mod)
    
    return {vars = {center.ability.extra.mult, xmult_total, enhanced_diamonds}}
  end,
  rarity = "poke_safari",
  cost = 10,
  stage = "Two",
  ptype = "Earth",
  atlas = "Pokedex3",
  blueprint_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.scoring_hand then
      -- Check for leftmost diamond card in the first hand of the round
      if context.before and not card.ability.extra.enhanced_this_round and G.GAME.current_round.hands_played == 0 and not context.blueprint then
        -- Find the leftmost diamond card in the hand
        local leftmost_diamond = nil
        for i = 1, #context.scoring_hand do
          if context.scoring_hand[i]:is_suit("Diamonds") and context.scoring_hand[i].ability.name == "Default Base" then
            leftmost_diamond = context.scoring_hand[i]
            break  -- Break after finding the leftmost one
          end
        end
        
        -- Enhance the leftmost diamond card if found
        if leftmost_diamond then
          card.ability.extra.enhanced_this_round = true
          
          -- Random enhancement (excluding Stone Card)
          local enhancement_type = pseudorandom(pseudoseed('flygon_enhance'))
          local enhancement = nil
          
          if enhancement_type > 0.857 then enhancement = G.P_CENTERS.m_bonus
          elseif enhancement_type > 0.714 then enhancement = G.P_CENTERS.m_mult
          elseif enhancement_type > 0.571 then enhancement = G.P_CENTERS.m_wild
          elseif enhancement_type > 0.428 then enhancement = G.P_CENTERS.m_glass
          elseif enhancement_type > 0.285 then enhancement = G.P_CENTERS.m_steel
          elseif enhancement_type > 0.142 then enhancement = G.P_CENTERS.m_gold
          else enhancement = G.P_CENTERS.m_lucky
          end
          
          leftmost_diamond:set_ability(enhancement, nil, true)
          G.E_MANAGER:add_event(Event({
            func = function()
              leftmost_diamond:juice_up()
              return true
            end
          }))
          
          card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_enhance'), colour = G.C.BLUE})
        end
      end
      
      if context.joker_main then
        -- Count enhanced diamond cards in deck
        local enhanced_diamonds = 0
        for _, v in ipairs(G.playing_cards) do
          if v:is_suit("Diamonds") and v.ability.name ~= "Default Base" then
            enhanced_diamonds = enhanced_diamonds + 1
          end
        end
        
        -- Calculate total XMult
        local xmult_total = card.ability.extra.Xmult + (enhanced_diamonds * card.ability.extra.Xmult_mod)
        
        return {
          message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.Xmult + (enhanced_diamonds * card.ability.extra.Xmult_mod)}},
          colour = G.C.MULT,
          mult_mod = card.ability.extra.mult,
          Xmult_mod = xmult_total
        }
      end
    end
    
    -- Check for diamond cards being played
    if context.individual and context.cardarea == G.play and context.other_card:is_suit("Diamonds") and not context.blueprint then
      -- Track diamond cards played and give +1 hand for first diamond in round
      if not card.ability.extra.diamond_played_this_round then
        card.ability.extra.diamond_played_this_round = true
        
        -- Grant temporary +1 hand for this round
        G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + 1
        
        return {
          message = localize('k_plus_hand'),
          colour = G.C.BLUE,
          card = card
        }
      end
    end
    
    -- Reset flags at end of round
    if context.end_of_round and not context.individual and not context.repetition then
      card.ability.extra.diamond_played_this_round = false
      card.ability.extra.enhanced_this_round = false
    end
  end
}
return {
  name = "Pokemon Jokers 301-330",
  list = {aron, lairon, aggron, trapinch, vibrava, flygon},
}
