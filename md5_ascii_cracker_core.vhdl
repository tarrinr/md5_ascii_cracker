library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


------------
-- ENTITY --
------------

entity md5_ascii_cracker_core is


    -------------
    -- GENERIC --
    -------------

    generic (

        index : integer

    );

    -----------
    -- PORTS --
    -----------

    port (

        clk : in std_logic;

        -- Inputs
        ascii_h : in unsigned(127 downto 0);

        -- Outputs
        ascii_f : out unsigned(511 downto 0);
        valid   : out std_logic

    );

end entity;


------------------
-- ARCHITECTURE --
------------------

architecture rtl of md5_ascii_cracker_core is


    ----------------
    -- COMPONENTS --
    ----------------

    component md5
    
        port (

            clk : in std_logic;

            -- Inputs
            frame : in unsigned(511 downto 0);

            -- Outputs
            hash   : out unsigned(127 downto 0);
            hash_f : out unsigned(511 downto 0)

        );

    end component;


    -------------
    -- SIGNALS --
    -------------

    signal frame : unsigned(511 downto 0);

    signal hash   : unsigned(127 downto 0);
    signal hash_f : unsigned(511 downto 0);

begin


    -----------------------------
    -- COMPONENT INSTANTIATION --
    -----------------------------

    md5_inst : md5

        port map (

            clk => clk,

            frame => frame,

            hash   => hash,
            hash_f => hash_f

        );


    ---------------
    -- PROCESSES --
    ---------------

    -- Message generator
    process (clk)
        variable cnt    : unsigned(447 downto 0) := to_unsigned(index mod 448, 448);
        variable length : unsigned(63 downto 0)  := to_unsigned(8,64);

    begin
        if rising_edge(clk) then
            frame <= length & (cnt or shift_left(to_unsigned(128,448), to_integer(length)));

            cnt := cnt + 64;
            if (cnt mod 256 ** (to_integer(length)/8)) = 0 then
                length := length + 8;
            end if;
        end if;
    end process;

    -- Search for match
    process (hash)
    begin
        if not is_X(std_logic_vector(hash)) then
            if hash = ascii_h then
                ascii_f <= hash_f;
                valid <= '1';
            else
                valid <= '0';
            end if;
        else
            valid <= '0';
        end if;
    end process;

end architecture;