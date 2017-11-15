select jsonb_pretty(data) -- Builds the output formant.
from magic.cards
where data @> '{
                "type":"Enchantment",
                "artist":"Jim Murray",
                "colors":["White"]
                }';
-- The @> operator reads contains and implements JSON searches.