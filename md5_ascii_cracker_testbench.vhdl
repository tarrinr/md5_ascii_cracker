library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;


------------
-- ENTITY --
------------

entity md5_ascii_cracker_testbench is
end entity;


------------------
-- ARCHITECTURE --
------------------

architecture rtl of md5_ascii_cracker_testbench is


    ----------------
    -- COMPONENTS --
    ----------------

    component md5_ascii_cracker
    
        port (

            clk : in std_logic;

            -- Inputs
            ascii_h : in unsigned(127 downto 0);

            -- Outputs
            ascii_f : out unsigned(511 downto 0)

        );

    end component;


    -------------
    -- SIGNALS --
    -------------
    
    signal clk : std_logic := '0';

    signal ascii_h : unsigned(127 downto 0) := x"93b885adfe0da089cdf634904fd59f71";
    signal ascii_f : unsigned(511 downto 0);

begin


    -----------------------------
    -- COMPONENT INSTANTIATION --
    -----------------------------

    md5_ascii_cracker_inst : md5_ascii_cracker

        port map (

            clk => clk,

            ascii_h => ascii_h,
            ascii_f => ascii_f

        );


    ---------------
    -- PROCESSES --
    ---------------

    -- Clock generator
    clock : process
    begin
        wait for 1 ns;
        clk <= not clk;
    end process;

    -- Found match
    process (ascii_f)
        variable l : line;
    begin
        if (not is_X(std_logic_vector(ascii_f))) and (ascii_f /= to_unsigned(0, 511)) then
            hwrite(l, std_logic_vector(ascii_f));
            writeline(output, l);
        end if;
    end process;

end architecture;