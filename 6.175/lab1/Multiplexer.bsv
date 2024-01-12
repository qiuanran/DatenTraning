function Bit#(1) and1(Bit#(1) a, Bit#(1) b);
    return a & b;
endfunction

function Bit#(1) or1(Bit#(1) a, Bit#(1) b);
    return a | b;
endfunction

function Bit#(1) xor1( Bit#(1) a, Bit#(1) b );
    return a ^ b;
endfunction

function Bit#(1) not1(Bit#(1) a);
    return ~ a;
endfunction

// EXE1 
function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    //return (sel == 0)? a : b;
    return or1(and1(a,not1(sel)),and1(b,sel));
endfunction

// EXE2
function Bit#(5) multiplexer5(Bit#(1) sel, Bit#(5) a, Bit#(5) b);
    Bit#(5) res;
    for (Integer i = 0; i < 5; i = i + 1)begin
        res[i] = multiplexer1(sel,a[i],b[i]);    
    end
    return res;
endfunction

typedef 5 N;
function Bit#(N) multiplexerN(Bit#(1) sel, Bit#(N) a, Bit#(N) b);
    Bit#(N) res;
    for (Integer i = 0; i < valueof(N); i = i + 1)begin
        res[i] = multiplexer1(sel,a[i],b[i]);    
    end
    return res;
endfunction

//typedef 32 N; // Not needed
// EXE3
function Bit#(n) multiplexer_n(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
    Bit#(n) res = 0;
    for (Integer i = 0; i < valueof(n); i = i + 1)begin
        res[i] = multiplexer1(sel,a[i],b[i]);    
    end
    return res;
endfunction
