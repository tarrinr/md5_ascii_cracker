library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


------------
-- ENTITY --
------------

entity md5 is


    -----------
    -- PORTS --
    -----------

    port (

        clk : in std_logic;

        -- Inputs
        frame : in unsigned(511 downto 0);

        -- Outputs
        hash   : out unsigned(127 downto 0);
        hash_f : out unsigned(511 downto 0)

    );

end entity;


------------------
-- ARCHITECTURE --
------------------

architecture rtl of md5 is


    ----------------
    -- COMPONENTS --
    ----------------

    component md5_core

        generic (

            index : integer;
            s     : integer;
            k     : unsigned(31 downto 0)

        );

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

    end component;


    ---------------
    -- FUNCTIONS --
    ---------------

    function flip_hash(
        hash_A : unsigned(31 downto 0);
        hash_B : unsigned(31 downto 0);
        hash_C : unsigned(31 downto 0);
        hash_D : unsigned(31 downto 0)
    )
        return unsigned is

        variable A : unsigned(31 downto 0) := hash_A(7 downto 0) & hash_A(15 downto 8) & hash_A(23 downto 16) & hash_A(31 downto 24);
        variable B : unsigned(31 downto 0) := hash_B(7 downto 0) & hash_B(15 downto 8) & hash_B(23 downto 16) & hash_B(31 downto 24);
        variable C : unsigned(31 downto 0) := hash_C(7 downto 0) & hash_C(15 downto 8) & hash_C(23 downto 16) & hash_C(31 downto 24);
        variable D : unsigned(31 downto 0) := hash_D(7 downto 0) & hash_D(15 downto 8) & hash_D(23 downto 16) & hash_D(31 downto 24);

    begin

        return A & B & C & D;

    end function;


    -------------------
    -- LOOKUP TABLES --
    -------------------

    type lut_s is array(63 downto 0) of integer;

    constant s : lut_s := (
        7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
        5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
        4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
        6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
    );

    type lut_k is array(63 downto 0) of unsigned(31 downto 0);

    constant k : lut_k := (
        x"d76aa478", x"e8c7b756", x"242070db", x"c1bdceee",
        x"f57c0faf", x"4787c62a", x"a8304613", x"fd469501",
        x"698098d8", x"8b44f7af", x"ffff5bb1", x"895cd7be",
        x"6b901122", x"fd987193", x"a679438e", x"49b40821",
        x"f61e2562", x"c040b340", x"265e5a51", x"e9b6c7aa",
        x"d62f105d", x"02441453", x"d8a1e681", x"e7d3fbc8",
        x"21e1cde6", x"c33707d6", x"f4d50d87", x"455a14ed",
        x"a9e3e905", x"fcefa3f8", x"676f02d9", x"8d2a4c8a",
        x"fffa3942", x"8771f681", x"6d9d6122", x"fde5380c",
        x"a4beea44", x"4bdecfa9", x"f6bb4b60", x"bebfbc70",
        x"289b7ec6", x"eaa127fa", x"d4ef3085", x"04881d05",
        x"d9d4d039", x"e6db99e5", x"1fa27cf8", x"c4ac5665",
        x"f4292244", x"432aff97", x"ab9423a7", x"fc93a039",
        x"655b59c3", x"8f0ccc92", x"ffeff47d", x"85845dd1",
        x"6fa87e4f", x"fe2ce6e0", x"a3014314", x"4e0811a1",
        x"f7537e82", x"bd3af235", x"2ad7d2bb", x"eb86d391"
    );


    -------------
    -- SIGNALS --
    -------------

    type connection   is array(64 downto 0) of unsigned(31 downto 0);
    type connection_f is array(64 downto 0) of unsigned(511 downto 0);

    signal connect_A : connection := (0 => x"67452301", others => x"00000000");
    signal connect_B : connection := (0 => x"efcdab89", others => x"00000000");
    signal connect_C : connection := (0 => x"98badcfe", others => x"00000000");
    signal connect_D : connection := (0 => x"10325476", others => x"00000000");
    signal connect_f : connection_f;

begin


    -----------------------------
    -- COMPONENT INSTANTIATION --
    -----------------------------

    md5_core_inst : for n in 63 downto 0 generate

        core : md5_core

            generic map(
                index => n,
                s => s(63-n),
                k => k(63-n)
            )

            port map(
                clk => clk,
        
                input_A => connect_A(n), 
                input_B => connect_B(n),
                input_C => connect_C(n),
                input_D => connect_D(n),
                input_f => connect_f(n),
        
                output_A => connect_A(n+1),
                output_B => connect_B(n+1),
                output_C => connect_C(n+1),
                output_D => connect_D(n+1),
                output_f => connect_f(n+1)
            );
    
    end generate;

    ---------------
    -- PROCESSES --
    ---------------

    process (clk)
    begin
        if rising_edge(clk) then

                connect_f(0) <= frame;
                hash <= flip_hash(connect_A(0) + connect_A(64), connect_B(0) + connect_B(64), connect_C(0) + connect_C(64), connect_D(0) + connect_D(64));
                hash_f <= connect_f(64);

        end if;
    end process;

end architecture;