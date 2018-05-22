library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


------------
-- ENTITY --
------------

entity md5_core is


    -------------
    -- GENERIC --
    -------------

    generic (

        index : integer;
        s     : integer;
        k     : unsigned(31 downto 0)

    );


    -----------
    -- PORTS --
    -----------

    port (

        clk : in std_logic;

        -- Inputs
        input_A : in unsigned(31 downto 0);
        input_B : in unsigned(31 downto 0);
        input_C : in unsigned(31 downto 0);
        input_D : in unsigned(31 downto 0);
        input_f : in unsigned(511 downto 0);

        -- Outputs
        output_A : out unsigned(31 downto 0);
        output_B : out unsigned(31 downto 0);
        output_C : out unsigned(31 downto 0);
        output_D : out unsigned(31 downto 0);
        output_f : out unsigned(511 downto 0)

    );

end entity;


------------------
-- ARCHITECTURE --
------------------

architecture rtl of md5_core is
begin


    ---------------
    -- PROCESSES --
    ---------------

    process (clk)
        variable F : unsigned(31 downto 0);
        variable g : integer;
    begin

        if rising_edge(clk) then
            
            case index is
                when 0 to 15 =>
                    F := (input_B and input_C) or ((not input_B) and input_D); --F function
                    g := index;
                when 16 to 31 =>
                    F := (input_D and input_B) or ((not input_D) and input_C); --G function
                    g := (5*index + 1) mod 16;
                when 32 to 47 =>
                    F := input_B xor input_C xor input_D; --H function
                    g := (3*index + 5) mod 16;
                when 48 to 63 =>
                    F := input_C xor (input_B or (not input_D)); --I function
                    g := (7*index) mod 16;
                when others =>
            end case;

            output_A <= input_D;
            output_C <= input_B;
            output_D <= input_C;
            output_f <= input_f;
            output_B <= input_B + rotate_left(input_A + F + input_f(g*32 + 31 downto g*32) + k, s);

        end if;

    end process;

end architecture;