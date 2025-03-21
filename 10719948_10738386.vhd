library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity project_reti_logiche is
    port (
        i_clk: in std_logic;    
        i_rst: in std_logic;
        i_start: in std_logic;
        i_add: in std_logic_vector(15 downto 0);
        i_k: in std_logic_vector(9 downto 0);
        
        o_done: out std_logic;
        
        o_mem_addr: out std_logic_vector(15 downto 0);
        i_mem_data: in std_logic_vector(7 downto 0);
        o_mem_data: out std_logic_vector(7 downto 0);
        o_mem_we: out std_logic;
        o_mem_en: out std_logic
    );
end project_reti_logiche;

architecture behavioral of project_reti_logiche is
    -- stati dell'FSA
    type status is (INIT, READING, WRITING_VAL, WRITING_CRED, BUFF);
    signal current_state: status;
    
    -- valore di credibilità
    signal credibility_val: std_logic_vector(7 downto 0);
    -- ultimo valore valido
    signal last_valid_val: std_logic_vector(7 downto 0);
    -- posto a 1 se l'automa ha concluso l'esecuzione
    signal has_finished: std_logic;
    -- posto a 1 se l'automa deve attendere la stabilizzazione dei segnali
    signal waiting: std_logic;
    -- indirizzo corrente
    signal current_addr: std_logic_vector(15 downto 0);
begin
    
    -- implementazione con macchina di Mealy
    process (i_clk, i_rst) is
    begin
        if i_rst = '1' then
            -- reset totale del componente
            current_state <= INIT;
            
            has_finished <= '0';
            waiting <= '0';
            
            o_mem_en <= '0';
            o_mem_we <= '0';
            o_done <= '0';
            o_mem_addr <= (others => '0');
            
        elsif rising_edge(i_clk) then
            case current_state is
            when INIT =>
                if i_start = '1' and has_finished = '0' then
                    waiting <= '0';
                    
                    -- abilito la lettura della memoria
                    o_mem_en <= '1';
                    o_mem_addr <= i_add;
                    current_addr <= i_add;
                    
                    -- inizializzo a zero per edge case
                    credibility_val <= (others => '0');
                    last_valid_val <= (others => '0');
                    
                    -- vado nello stato di buffering
                    current_state <= BUFF;
                elsif i_start = '0' then
                    -- termino la computazione pronto per una nuova elaborazione
                    o_done <= '0';
                    has_finished <= '0';
                end if;

            when READING =>
                -- leggo un valore valido
                if i_mem_data /= "00000000" then
                    -- aggiorno l'ultimo valore valido a quello corrente
                    last_valid_val <= i_mem_data; 
                                       
                    -- pongo il valore di credibility a 31
                    credibility_val <= "00011111";
                    
                    -- al prossimo ciclo di clock devo andare all'indirizzo corrispondente ad un valore di credibilità
                    current_addr <= std_logic_vector(signed(current_addr) + 1);
                    
                    -- vado nello stato di scrittura di credibilità
                    current_state <= WRITING_CRED;
                else
                    -- vado nello stato di scrittura del dato mancante
                    current_state <= WRITING_VAL;
                end if;

            when WRITING_VAL =>
                -- abilito la scrittura in memoria per il ciclo di clock corrente
                o_mem_we <= '1';
                -- scrivo l'ultimo valore valido
                o_mem_data <= last_valid_val;
                
                -- decremento il valore di credibilità (se possibile)
                if credibility_val /= "00000000" then
                    credibility_val <= std_logic_vector(signed(credibility_val) - 1);
                end if;
                
                -- al prossimo ciclo di clock devo andare in addr + 1
                current_addr <= std_logic_vector(signed(current_addr) + 1);
                -- al prossimo ciclo di clock devo scrivere il valore di credibilità
                current_state <= WRITING_CRED;

            when WRITING_CRED =>
                -- abilito la scrittura in memoria per il ciclo di clock
                o_mem_we <= '1';
                o_mem_addr <= current_addr;
                
                -- scrivo il valore di credibilità in memoria
                o_mem_data <= credibility_val;
                                
                -- verifico di aver concluso
                if current_addr = std_logic_vector(signed(i_add) + signed(i_k) + signed(i_k) - 1) then
                    has_finished <= '1';
                end if;
                
                -- al prossimo ciclo di clock devo andare in addr + 1
                current_addr <= std_logic_vector(signed(current_addr) + 1);
                
                -- devo attendere lo stabilizzarsi dei segnali nello stato di buffer
                waiting <= '1';
                current_state <= BUFF;

            when BUFF =>
                o_mem_we <= '0';
                
                if has_finished = '1' then
                    -- computazione completata
                    o_mem_en <= '0';                    
                    o_done <= '1';
                    current_state <= INIT;
                elsif waiting = '1' then
                    -- attendo per un ciclo di clock affinchè i segnali si stabilizzino
                    o_mem_addr <= current_addr;
                    waiting <= '0';
                    current_state <= BUFF;
                else
                    -- vado nello stato di reading dopo aver atteso 
                    o_mem_addr <= current_addr;
                    current_state <= READING;
                end if;
            end case;
        end if;            
    end process;
end behavioral;