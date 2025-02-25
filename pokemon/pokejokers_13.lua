-- Snorunt 361
local snorunt={
  name = "snorunt",
  pos = {x = 2, y = 11},
  config = {extra = {debt = 15,rounds = 4}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    return {vars = {center.ability.extra.debt, center.ability.extra.rounds}}
  end,
  rarity = 1,
  cost = 4,
  item_req = "dawnstone",
  stage = "Basic",
  ptype = "Water",
  atlas = "Pokedex3",
  perishable_compat = true,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    local evolve = item_evo(self, card, context, "j_poke_froslass")
    if evolve then
      return evolve
    else
      local in_debt = nil
      if (SMODS.Mods["Talisman"] or {}).can_load then
        in_debt = to_big(G.GAME.dollars) < to_big(0)
      else
        in_debt = G.GAME.dollars < 0
      end
      if in_debt then
        return level_evo(self, card, context, "j_poke_glalie")
      end
    end
  end,
  add_to_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.bankrupt_at = G.GAME.bankrupt_at - card.ability.extra.debt
    end
  end,
  remove_from_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.bankrupt_at = G.GAME.bankrupt_at + card.ability.extra.debt
    end
  end,
}
-- Glalie 362
local glalie={
  name = "glalie",
  pos = {x = 3, y = 11},
  config = {extra = {debt = 20}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    return {vars = {center.ability.extra.debt}}
  end,
  rarity = "poke_safari",
  cost = 8,
  stage = "One",
  ptype = "Water",
  atlas = "Pokedex3",
  perishable_compat = true,
  blueprint_compat = true,
  eternal_compat = true,
  calculate = function(self, card, context)
    if context.end_of_round and not context.individual and not context.repetition then
      card:juice_up()
      local back_to_zero = 0
      if (SMODS.Mods["Talisman"] or {}).can_load then
        back_to_zero = to_number(-G.GAME.dollars)
      else
        back_to_zero = -G.GAME.dollars
      end
      ease_dollars(back_to_zero, true)
    end
  end,
  add_to_deck = function(self, card, from_debuff)
    G.GAME.bankrupt_at = G.GAME.bankrupt_at - card.ability.extra.debt
  end,
  remove_from_deck = function(self, card, from_debuff)
    G.GAME.bankrupt_at = G.GAME.bankrupt_at + card.ability.extra.debt
  end,
}
local spheal = {
    name = "spheal",
    pos = {x = 4, y = 11},
    config = {extra = {
        chips = 4,         -- Base chip value
        mult = 2,          -- Starting mult value
        glass_cards = 0,   -- Tracks glass cards played
        fail_chance = 20   -- 20% chance to fail
    }},
    loc_vars = function(self, info_queue, center)
        type_tooltip(self, info_queue, center)
        info_queue[#info_queue+1] = {key = 'percent_chance', set = 'Other', specific_vars = {center.ability.extra.fail_chance}}
        return {vars = {
            center.ability.extra.chips,
            center.ability.extra.mult,
            center.ability.extra.glass_cards
        }}
    end,
    rarity = 2,
    cost = 4,
    stage = "Basic",
    ptype = "Water",
    atlas = "Pokedex3",
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.scoring_hand then
            if context.joker_main then
                return {
                    message = localize{type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult}},
                    colour = G.C.RED,
                    chip_mod = card.ability.extra.chips,
                    mult_mod = card.ability.extra.mult
                }
            end
        end
        if context.individual and context.cardarea == G.play and 
           not context.end_of_round and context.other_card.ability.name == 'Glass Card' then
            card.ability.extra.glass_cards = card.ability.extra.glass_cards + 1
            
            if not context.repetition and pseudorandom('spheal_rollout') < card.ability.extra.fail_chance/100 then
                card.ability.extra.mult = math.floor(card.ability.extra.mult / 2)
                card.ability.extra.chips = math.floor(card.ability.extra.chips / 2)
                
                if not context.blueprint then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('poke_miss_ex'), colour = G.C.RED})
                end
                
            else
                card.ability.extra.chips = card.ability.extra.chips + 4
                card.ability.extra.mult = card.ability.extra.mult + 2
                
                if not context.blueprint and not context.repetition then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('poke_rollout_ex'), colour = G.C.BLUE})
                    card:juice_up()
                end
                
            end
        end
        return scaling_evo(self, card, context, "j_poke_sealeo", card.ability.extra.glass_cards, 2)
    end
}

-- Sealeo 364
local sealeo = {
    name = "sealeo",
    pos = {x = 5, y = 11},
    config = {extra = {
        chips = 8,        -- Base chip value
        mult = 4,          -- Starting mult value  
        glass_cards = 0,   -- Tracks glass cards played
        fail_chance = 15   -- 15% chance to fail
    }},
    loc_vars = function(self, info_queue, center)
        type_tooltip(self, info_queue, center)
        info_queue[#info_queue+1] = {key = 'percent_chance', set = 'Other', specific_vars = {center.ability.extra.fail_chance}}
        return {vars = {
            center.ability.extra.chips,
            center.ability.extra.mult,
            center.ability.extra.glass_cards
        }}
    end,
    rarity = "poke_safari",
    cost = 6,
    stage = "One",
    ptype = "Water",
    atlas = "Pokedex3",
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.scoring_hand then
            if context.joker_main then
                return {
                    message = localize{type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult}},
                    colour = G.C.MULT,
                    chip_mod = card.ability.extra.chips,
                    mult_mod = card.ability.extra.mult
                }
            end
        end
        if context.individual and context.cardarea == G.play and 
           not context.end_of_round and context.other_card.ability.name == 'Glass Card' then
            card.ability.extra.glass_cards = card.ability.extra.glass_cards + 1
            
            if not context.repetition and pseudorandom('sealeo_rollout') < card.ability.extra.fail_chance/100 then
                card.ability.extra.mult = math.floor(card.ability.extra.mult / 2)
                card.ability.extra.chips = math.floor(card.ability.extra.chips / 2)
                
                if not context.blueprint then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('poke_miss_ex'), colour = G.C.RED})
                end
                
            else
                card.ability.extra.chips = card.ability.extra.chips + 8
                card.ability.extra.mult = card.ability.extra.mult + 4
                
                if not context.blueprint and not context.repetition then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('poke_rollout_ex'), colour = G.C.BLUE})
                    card:juice_up()
                end
                
            end
        end
        return scaling_evo(self, card, context, "j_poke_walrein", card.ability.extra.glass_cards, 8)
    end,
    set_ability = function(self, card)
        if card.ability.prev_card then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.prev_card.ability.extra.chips
            card.ability.extra.mult = card.ability.extra.mult + card.ability.prev_card.ability.extra.mult
            card.ability.extra.glass_cards = card.ability.prev_card.ability.extra.glass_cards
        end
    end
}
-- Walrein 365
local walrein = {
   name = "walrein",
   pos = {x = 6, y = 11},
   config = {extra = {
       chips = 12,        -- Base chip value
       mult = 6,         -- Starting mult value
       glass_cards = 0,   -- Tracks glass cards played
       fail_chance = 10,   -- 10% chance to fail when glass card played
       Xmult = 1.0,      -- Starting X Mult value
       Xmult_mod = 0.05  -- X Mult increase per glass card
   }},
   loc_vars = function(self, info_queue, center)
       type_tooltip(self, info_queue, center)
       info_queue[#info_queue+1] = {key = 'percent_chance', set = 'Other', specific_vars = {center.ability.extra.fail_chance}}
       return {vars = {
           center.ability.extra.chips,
           center.ability.extra.mult,
           center.ability.extra.glass_cards,
		   center.ability.extra.Xmult,
		   center.ability.extra.Xmult_mod,
		   center.ability.extra.Xmult + (center.ability.extra.glass_cards * center.ability.extra.Xmult_mod)
       }}
   end,
   rarity = "poke_safari",
   cost = 10,
   stage = "Two",
   ptype = "Water",
   atlas = "Pokedex3",
   blueprint_compat = true,
   calculate = function(self, card, context)
       if context.cardarea == G.jokers and context.scoring_hand then
           if context.joker_main then
               return {
                   message = localize{type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult}},
                   colour = G.C.RED,
                   chip_mod = card.ability.extra.chips,
                   mult_mod = card.ability.extra.mult,
                   Xmult_mod = card.ability.extra.Xmult + (card.ability.extra.glass_cards * card.ability.extra.Xmult_mod)
               }
           end
       end
       if context.individual and context.cardarea == G.play and 
          not context.end_of_round and context.other_card.ability.name == 'Glass Card' then
           card.ability.extra.glass_cards = card.ability.extra.glass_cards + 1
           
           -- Check for failure (10% chance)
           if pseudorandom('spheal_rollout') < card.ability.extra.fail_chance/100 then
               card.ability.extra.mult = math.floor(card.ability.extra.mult / 2)
               card.ability.extra.chips = math.floor(card.ability.extra.chips / 2)
               
               card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('poke_miss_ex'), colour = G.C.RED})
               
           else
               card.ability.extra.chips = card.ability.extra.chips + 12
               card.ability.extra.mult = card.ability.extra.mult + 6
               
               card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('poke_rollout_ex'), colour = G.C.BLUE})
               card:juice_up()
               
           end
       end
   end
}
-- Clamperl 366
-- Huntail 367
-- Gorebyss 368
-- Relicanth 369
-- Luvdisc 370
-- Bagon 371
-- Shelgon 372
-- Salamence 373
-- Beldum 374
local beldum={
  name = "beldum", 
  pos = {x = 5, y = 12},
  config = {extra = {chips = 0, chip_mod = 8, size = 4}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    return {vars = {center.ability.extra.chips, center.ability.extra.chip_mod, center.ability.extra.size}}
  end,
  rarity = 2, 
  cost = 6, 
  stage = "Basic", 
  ptype = "Metal",
  atlas = "Pokedex3",
  perishable_compat = false,
  blueprint_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.scoring_hand then
      if context.before and not context.blueprint then
        local has_ace = false
        for i = 1, #context.scoring_hand do
            if context.scoring_hand[i]:get_id() == 14 then has_ace = true; break end
        end
        if has_ace then
          if context.scoring_name == "Four of a Kind" then
            card.ability.extra.chips = card.ability.extra.chips + 2 * card.ability.extra.chip_mod
          else
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
          end
        end
      end
      if context.joker_main then
        
        return {
          message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}, 
          colour = G.C.CHIPS,
          chip_mod = card.ability.extra.chips,
        }
      end
    end
    return scaling_evo(self, card, context, "j_poke_metang", card.ability.extra.chips, 64)
  end,
}
-- Metang 375
local metang={
  name = "metang", 
  pos = {x = 6, y = 12},
  config = {extra = {chips = 0, chip_mod = 8, size = 4}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    return {vars = {center.ability.extra.chips, center.ability.extra.chip_mod, center.ability.extra.size}}
  end,
  rarity = "poke_safari", 
  cost = 8, 
  stage = "One", 
  ptype = "Metal",
  atlas = "Pokedex3",
  perishable_compat = false,
  blueprint_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.scoring_hand then
      if context.before and not context.blueprint then
        local ace_count = 0
        for i = 1, #context.scoring_hand do
            if context.scoring_hand[i]:get_id() == 14 then ace_count = ace_count + 1 end
        end
        if ace_count > 1 then
          if context.scoring_name == "Four of a Kind" then
            card.ability.extra.chips = card.ability.extra.chips + 4 * card.ability.extra.chip_mod
          else
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
          end
        end
      end
      if context.joker_main then
        return {
          message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}, 
          colour = G.C.CHIPS,
          chip_mod = card.ability.extra.chips,
          card = card
        }
      end
    end
    return scaling_evo(self, card, context, "j_poke_metagross", card.ability.extra.chips, 256)
  end,
}
-- Metagross 376
local metagross={
  name = "metagross", 
  pos = {x = 7, y = 12},
  config = {extra = {chips = 256,}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    return {vars = {center.ability.extra.chips}}
  end,
  rarity = "poke_safari", 
  cost = 10, 
  stage = "Two", 
  ptype = "Metal",
  atlas = "Pokedex3",
  perishable_compat = false,
  blueprint_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.scoring_hand then
      if context.joker_main then
        return {
          message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}, 
          colour = G.C.CHIPS,
          chip_mod = card.ability.extra.chips,
          card = card
        }
      end
    end
    if context.individual and context.cardarea == G.play and not context.end_of_round and context.scoring_name and context.scoring_name == "Four of a Kind" then
      local total_chips = poke_total_chips(context.other_card)
      local Xmult = (total_chips)^(1/3)
      if Xmult > 0 then
        return {
          message = localize{type = 'variable', key = 'a_xmult', vars = {Xmult}},
          colour = G.C.XMULT,
          mult = card.ability.extra.mult_mod, 
          x_mult = Xmult,
          card = card
        }
      end
    end
  end,
}
-- Regirock 377
-- Regice 378
-- Registeel 379
-- Latias 380
-- Latios 381
-- Kyogre 382
-- Groudon 383
-- Rayquaza 384
-- Jirachi 385
-- Deoxys 386
-- Turtwig 387
-- Grotle 388
-- Torterra 389
-- Chimchar 390
return {name = "Pokemon Jokers 361-390", 
        list = {snorunt, glalie, spheal, sealeo, walrein, beldum, metang, metagross},
}
