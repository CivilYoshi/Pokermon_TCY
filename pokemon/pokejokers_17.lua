-- Mesprit 481
-- Azelf 482
-- Dialga 483
-- Palkia 484
-- Heatran 485
local heatran = {
  name = "heatran",
  pos = {x = 10, y = 7},
  soul_pos = {x = 11, y = 7},
  config = {extra = {triggered_editions = 0}},
  loc_vars = function(self, info_queue, center)
    type_tooltip(self, info_queue, center)
    info_queue[#info_queue+1] = G.P_CENTERS.m_steel
	info_queue[#info_queue+1] = G.P_CENTERS.c_immolate
    return {vars = {center.ability.extra.triggered_editions}}
  end,
  rarity = 4,
  cost = 15,
  stage = "Legendary",
  ptype = "Fire",
  atlas = "Pokedex4",
  blueprint_compat = true,
calculate = function(self, card, context)
  -- Gain an immolate card every Big Blind and Boss blind
  if context.setting_blind and not card.getting_sliced then
    if context.blind == G.P_BLINDS.bl_big or (context.blind and context.blind.boss) then
      if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        local immolate_card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_immolate')
        immolate_card:add_to_deck()
        G.consumeables:emplace(immolate_card)
        card_eval_status_text(immolate_card, 'extra', nil, nil, nil, {
          message = localize('k_plus_spectral'),
          colour = G.C.SECONDARY_SET.Spectral
        })
      end
    end
  end
      
  -- When steel cards with an edition are triggered from hand
  if context.individual and context.cardarea == G.hand and context.scoring_hand then
    if context.other_card.ability.name == 'Steel Card' and context.other_card.edition then
      -- Activate edition effects
      if context.other_card.edition.polychrome then
        return {
          x_mult = 1.5,
          card = card
        }
      elseif context.other_card.edition.holo then
        return {
          mult = 10,
          card = card
        }
      elseif context.other_card.edition.foil then
        return {
          chips = 50,
          card = card
        }
      end
    end
  end
      
  -- When steel cards in hand are destroyed
  if context.remove_playing_cards and context.removed then
    for k, destroyed_card in ipairs(context.removed) do
      if destroyed_card and destroyed_card.ability and destroyed_card.ability.name == 'Steel Card' then
        -- Random edition (25% chance Polychrome, 35% Holographic, 40% Foil)
        local edition_roll = pseudorandom('heatran_edition')
        local edition = {}
        
        if edition_roll < 0.25 then
          edition = {polychrome = true}
        elseif edition_roll < 0.60 then
          edition = {holo = true}
        else
          edition = {foil = true}
        end
        
        -- Create a steel card with the same suit and rank as the destroyed card
        local new_card = create_playing_card({
          front = destroyed_card.config.card, -- Use original card's front (suit and rank) 
          center = G.P_CENTERS.m_steel
        }, G.deck, true)
        
        new_card:set_edition(edition, true)
        
        G.E_MANAGER:add_event(Event({
          func = function()
            card:juice_up()
            return true
          end
        }))
        
        card_eval_status_text(card, 'extra', nil, nil, nil, {
          message = localize('poke_magma_storm_ex'),
          colour = G.C.BLUE
        })
        
        -- Track edition triggering
        card.ability.extra.triggered_editions = card.ability.extra.triggered_editions + 1
      end
    end
  end
end
}
-- Regigigas 486
-- Giratina 487
-- Cresselia 488
-- Phione 489
-- Manaphy 490
-- Darkrai 491
-- Shaymin 492
-- Arceus 493
-- Victini 494
-- Snivy 495
-- Servine 496
-- Serperior 497
-- Tepig 498
-- Pignite 499
-- Emboar 500
-- Oshawott 501
-- Dewott 502
-- Samurott 503
-- Patrat 504
-- Watchog 505
-- Lillipup 506
-- Herdier 507
-- Stoutland 508
-- Purrloin 509
-- Liepard 510
return {name = "Pokemon Jokers 481-510", 
        list = {heatran},
}