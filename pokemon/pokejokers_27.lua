-- Dhelmise 781
-- Jangmo-o 782
-- Hakamo-o 783
-- Kommo-o 784
-- Tapu Koko 785
-- Tapu Lele 786
-- Tapu Bulu 787
-- Tapu Fini 788
-- Cosmog 789
-- Cosmoem 790
-- Solgaleo 791
-- Lunala 792
-- Nihilego 793
-- Buzzwole 794
-- Pheromosa 795
-- Xurkitree 796
local xurkitree = {
    name = "xurkitree",
    pos = {x = 4, y = 7},
    soul_pos = {x = 5, y = 7},
    config = {extra = {h_dollars = 2, h_x_mult = 1.37, Xmult = 1}},
    loc_vars = function(self, info_queue, center)
        type_tooltip(self, info_queue, center)
        info_queue[#info_queue+1] = G.P_CENTERS.m_steel
        info_queue[#info_queue+1] = G.P_CENTERS.m_gold
        
        -- Count current pairs in hand
        local steel_count = 0
        local gold_count = 0
        if G.hand and G.hand.cards then
            for _, v in ipairs(G.hand.cards) do
                if v.ability.name == 'Steel Card' then
                    steel_count = steel_count + 1
                elseif v.ability.name == 'Gold Card' then
                    gold_count = gold_count + 1
                end
            end
        end
        local current_pairs = math.min(steel_count, gold_count)
        
        return {vars = {center.ability.extra.h_dollars, center.ability.extra.h_x_mult, current_pairs + 1}}
    end,
    rarity = "poke_ultrabeast",
    cost = 8,
    stage = "Ultra Beast",
    ptype = "Lightning",
    atlas = "Pokedex7",
    blueprint_compat = true,
    calculate = function(self, card, context)
        -- Handle pairs multiplier at end of hand
        if context.cardarea == G.jokers and context.scoring_hand then
            if context.joker_main then
                local steel_count = 0
                local gold_count = 0
                
                for _, v in ipairs(G.hand.cards) do
                    if v.ability.name == 'Steel Card' then
                        steel_count = steel_count + 1
                    elseif v.ability.name == 'Gold Card' then
                        gold_count = gold_count + 1
                    end
                end
                
                local pairs = math.min(steel_count, gold_count)
                if pairs > 0 then
                    return {
                        message = localize('poke_boost_ex'),
                        colour = G.C.XMULT,
                        Xmult_mod = pairs + 1
                    }
                end
            end
        end
        
        -- Handle individual card effects in hand
        if context.individual and context.cardarea == G.hand then
            if context.other_card.ability.name == 'Steel Card' then
                return {
                    dollars = card.ability.extra.h_dollars
                }
            elseif context.other_card.ability.name == 'Gold Card' then
                return {
                    x_mult = card.ability.extra.h_x_mult,
                }
            end
        end
    end
}
-- Celesteela 797
-- Kartana 798
-- Guzzlord 799
local guzzlord = {
    name = "guzzlord",
    pos = {x = 10, y = 7},
    soul_pos = {x = 11, y = 7},
    config = {extra = {
        Perm_Xmult = 1,    -- Tracks permanent X mult gains (starts at 1)
        Perm_mult = 0,     -- Tracks permanent mult gains
        Perm_chips = 0,    -- Tracks permanent chip gains
		Xmult = 1,
		mult = 1,
		chips = 1,
        odds_joker = 3,    -- 1/3 chance for jokers
        odds_consumable = 3, -- 1/3 chance for consumables
        odds_discard = 13,   -- 1/13 chance for discards
        Xmult_gain = 0.29,  -- X mult gained per consume
        mult_gain = 3,      -- Mult gained per consume
        chip_gain = 9      -- Chips gained per consume
    }},
    loc_vars = function(self, info_queue, center)
        type_tooltip(self, info_queue, center)
        
        return {vars = {
            ''..(G.GAME and G.GAME.probabilities.normal or 1),  -- #1 current probability
            center.ability.extra.odds_joker,                     -- #2 odds for joker/consumable
            center.ability.extra.odds_discard,                   -- #3 odds for discard
            center.ability.extra.Perm_Xmult * center.ability.extra.Xmult,                    -- #4 current X Mult
            center.ability.extra.Perm_mult * center.ability.extra.mult,                     -- #5 current Mult
            center.ability.extra.Perm_chips * center.ability.extra.chips                    -- #6 current Chips
        }}
    end,
    rarity = "poke_ultrabeast",
    cost = 8,
    stage = "Ultra Beast",
    ptype = "Dragon",
    atlas = "Pokedex7",
    blueprint_compat = true,
    calculate = function(self, card, context)
        -- Handle joker/consumable purchases and additions
        if context.card and context.card ~= card and not context.selling_self and not context.selling_card then
            -- For jokers
            if context.card.ability.set == 'Joker' then
                if pseudorandom('guzzlord_joker') < G.GAME.probabilities.normal/card.ability.extra.odds_joker then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        func = function()
                            card.ability.extra.Perm_Xmult = card.ability.extra.Perm_Xmult + card.ability.extra.Xmult_gain
                            G.jokers:remove_card(context.card)
                            context.card:remove()
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = localize('poke_consume_ex'),
                                colour = G.C.RED
                            })
                            return true
                        end
                    }))
                end
            -- For consumables
            elseif context.card.ability.consumeable then
                if pseudorandom('guzzlord_consumable') < G.GAME.probabilities.normal/card.ability.extra.odds_consumable then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        func = function()
                            card.ability.extra.Perm_mult = card.ability.extra.Perm_mult + card.ability.extra.mult_gain
                            G.consumeables:remove_card(context.card)
                            context.card:remove()
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = localize('poke_consume_ex'),
                                colour = G.C.RED
                            })
                            return true
                        end
                    }))
                end
            end
        end

        -- Handle discards
        if context.discard then
            if pseudorandom('guzzlord_discard') < G.GAME.probabilities.normal/card.ability.extra.odds_discard then
                -- Consume the discarded card
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        card.ability.extra.Perm_chips = card.ability.extra.Perm_chips + card.ability.extra.chip_gain
                        context.other_card:start_dissolve()
                        delay(0.3)
                        for i = 1, #G.jokers.cards do
                            G.jokers.cards[i]:calculate_joker({remove_playing_cards = true, removed = {context.other_card}})
                        end
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = localize('poke_consume_ex'),
                            colour = G.C.RED
                        })
                        return true
                    end
                }))
            end
        end

        -- Apply permanent stat bonuses during scoring
        if context.cardarea == G.jokers and context.scoring_hand then
            if context.joker_main then
                local ret = {}
                if card.ability.extra.Perm_Xmult > 0 then
                    ret.Xmult_mod = card.ability.extra.Perm_Xmult * card.ability.extra.Xmult
                end
                if card.ability.extra.Perm_mult > 0 then
                    ret.mult_mod = card.ability.extra.Perm_mult * card.ability.extra.mult
                end
                if card.ability.extra.Perm_chips > 0 then
                    ret.chip_mod = card.ability.extra.Perm_chips * card.ability.extra.chips
                end
                
                if next(ret) then
                    ret.message = localize('poke_boost_ex')
                    ret.colour = G.C.RED
                    return ret
                end
            end
        end
    end
}
-- Necrozma 800
-- Magearna 801
-- Marshadow 802
-- Poipole 803
-- Naganadel 804
-- Stakataka 805
local stakataka = {
    name = "stakataka",
    pos = {x = 12, y = 8},
    soul_pos = {x = 13, y = 8},
    config = {extra = {
        chips = 0,          -- Tracks chip gains
        Xmult = 0.17,       -- X mult gained per prime number
        prime_count = 0,    -- Tracks how many prime numbers match deck size
        next_prime = 0      -- Tracks the next prime number beyond current deck size
    }},
    loc_vars = function(self, info_queue, center)
        type_tooltip(self, info_queue, center)
        
        return {vars = {
            center.ability.extra.Xmult,      -- #1 X mult per prime number
            center.ability.extra.prime_count, -- #2 count of prime numbers
            center.ability.extra.chips,      -- #3 current Chips
            1 + (center.ability.extra.prime_count * center.ability.extra.Xmult), -- #4 total X mult
            center.ability.extra.next_prime  -- #5 next prime number target
        }}
    end,
    rarity = "poke_ultrabeast",
    cost = 9,
    stage = "Ultra Beast",
    ptype = "Earth",
    atlas = "Pokedex7",
    blueprint_compat = true,
    -- Predefined list of prime numbers up to 700
    primes = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 
    73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 
    179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 
    283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 
    419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 
    547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 
    661, 673, 677, 683, 691, 697},
    
    -- Find the next prime after a given number
    find_next_prime = function(self, current_size)
        for _, prime in ipairs(self.primes) do
            if prime > current_size then
                return prime
            end
        end
        -- If no next prime is found in our list, return the last one + 2
        -- (just a placeholder, as we might have reached the end of our list)
        return self.primes[#self.primes] + 2
    end,
    
    calculate = function(self, card, context)
        -- Calculate prime-related bonuses at the beginning of scoring
        if context.cardarea == G.jokers and context.scoring_hand and context.before and not context.blueprint then
            -- Reset counts
            card.ability.extra.prime_count = 0
            local prime_sum = 0
            local deck_size = #G.playing_cards
            
            -- Find the next prime beyond current deck size
            card.ability.extra.next_prime = self:find_next_prime(deck_size)
            
            -- Check for prime numbers less than or equal to the deck size
            for _, prime in ipairs(self.primes) do
                if prime <= deck_size then
                    card.ability.extra.prime_count = card.ability.extra.prime_count + 1
                    prime_sum = prime_sum + prime
                end
            end
            
            -- Update chips based on cumulative sum of relevant primes
            card.ability.extra.chips = prime_sum
        end
        
        -- Apply effects when scoring
        if context.cardarea == G.jokers and context.scoring_hand and context.joker_main then
            if card.ability.extra.prime_count > 0 then
                local xmult_bonus = 1 + (card.ability.extra.prime_count * card.ability.extra.Xmult)
                
                return {
                    message = localize("poke_boost_ex"),
                    colour = G.C.ULTRA,
                    Xmult_mod = xmult_bonus,
                    chip_mod = card.ability.extra.chips,
                    card = card
                }
            end
        end
    end,
    update = function(self, card, dt)
        if G.STAGE == G.STAGES.RUN then
            -- Only update periodically to reduce performance impact
            card.ability.update_timer = (card.ability.update_timer or 0) + dt
            if card.ability.update_timer < 0.5 then return end
            card.ability.update_timer = 0
            
            if G.playing_cards then
                -- Reset counts
                local prime_count = 0
                local prime_sum = 0
                local deck_size = #G.playing_cards
                
                -- Find the next prime beyond current deck size
                card.ability.extra.next_prime = self:find_next_prime(deck_size)
                
                -- Check for prime numbers less than or equal to the deck size
                for _, prime in ipairs(self.primes) do
                    if prime <= deck_size then
                        prime_count = prime_count + 1
                        prime_sum = prime_sum + prime
                    end
                end
                
                -- Only update if values have changed
                if prime_count ~= card.ability.extra.prime_count or prime_sum ~= card.ability.extra.chips then
                    card.ability.extra.prime_count = prime_count
                    card.ability.extra.chips = prime_sum
                end
            end
        end
    end
}

-- Blacephalon 806
local blacephalon = {
   name = "blacephalon",
   pos = {x = 0, y = 9},
   soul_pos = {x = 1, y = 9},
   config = {extra = {
       mult = 1,             -- Current accumulated mult
       times_disabled = 0,   -- Track number of times disabled 
       d_size = 1,          -- Number of extra discards provided
       Xmult = 1.0,         -- Current Xmult value
	   Xmult_mod4 = 1.0,
       current_ante = 0,     -- Track current ante for resets
       cards_discarded = 0,	   -- Track discards this ante
	   debuff_real = 0
   }},
   loc_vars = function(self, info_queue, center)
       type_tooltip(self, info_queue, center)
       return {vars = {
           (center.ability.extra.cards_discarded) * 3 * center.ability.extra.mult, -- Current total mult
           center.ability.extra.Xmult * center.ability.extra.Xmult_mod4 -- Current Xmult
       }}
   end,
   rarity = "poke_ultrabeast",
   cost = 12,
   stage = "Ultra Beast",
   ptype = "Psychic",
   atlas = "Pokedex7",
   blueprint_compat = false,
   calculate = function(self, card, context)
       -- Initialize if needed
       if not card.ability.extra.cards_discarded then
           card.ability.extra.cards_discarded = 0
       end

       -- Reset card capabilities ONLY when ante increases
       if G.GAME.round_resets.ante ~= card.ability.extra.current_ante then
           card.ability.extra.current_ante = G.GAME.round_resets.ante  -- Store new ante
           card.ability.extra.cards_discarded = 0                      -- Reset discard counter
		   card.ability.extra.debuff_real = 0
           card.debuff = false                                         -- Enable card again
       end 
	   
	   if card.ability.extra.debuff_real == 1 then 
	       card.debuff = true
	   end

       -- Force disabled state if the card was disabled this ante
       -- if card.debuff and G.GAME.round_resets.ante == card.ability.extra.current_ante then
           -- -- Hard force disabled state without increasing Xmult again
           -- G.E_MANAGER:add_event(Event({
               -- func = function()
                   -- card.debuff = true
                   -- return true
               -- end
           -- }))
       -- end

       -- Track discards
       if context.discard and not context.blueprint then
           card.ability.extra.cards_discarded = card.ability.extra.cards_discarded + 1
       end

       -- Main scoring logic
       if context.cardarea == G.jokers and context.scoring_hand and not context.blueprint then
           if context.joker_main and G.jokers.cards[1] == card and not card.debuff then
               -- Disable card and increase permanent Xmult
               G.E_MANAGER:add_event(Event({
                   func = function()
                       card.debuff = true
                       card.ability.extra.times_disabled = card.ability.extra.times_disabled + 1
                       card.ability.extra.Xmult_mod4 = 1.0 + (card.ability.extra.times_disabled * 0.67)
					   card.ability.extra.debuff_real = 1
                       return true
                   end
               }))

               return {
                   message = localize("poke_explosion_ex"),
                   colour = G.C.MULT,
                   mult_mod = card.ability.extra.cards_discarded * 7 * card.ability.extra.mult,
                   Xmult_mod4 = 1.0 + card.ability.extra.Xmult * card.ability.extra.Xmult_mod4
               }
           end
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
   end
}
-- Zeraora 807
-- Meltan 808
-- Melmetal 809
-- Grookey 810
return {name = "Pokemon Jokers 781-810", 
        list = {xurkitree, guzzlord, stakataka, blacephalon},
}