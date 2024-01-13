// Reference functions that use Bluespec's '*' operator
function Bit#(TAdd#(n,n)) multiply_unsigned( Bit#(n) a, Bit#(n) b );
    UInt#(n) a_uint = unpack(a);
    UInt#(n) b_uint = unpack(b);
    UInt#(TAdd#(n,n)) product_uint = zeroExtend(a_uint) * zeroExtend(b_uint);
    return pack( product_uint );
endfunction

function Bit#(TAdd#(n,n)) multiply_signed( Bit#(n) a, Bit#(n) b );
    Int#(n) a_int = unpack(a);
    Int#(n) b_int = unpack(b);
    Int#(TAdd#(n,n)) product_int = signExtend(a_int) * signExtend(b_int);
    return pack( product_int );
endfunction

// unsigned add function
function Bit#(TAdd#(n,1)) add_unsigned( Bit#(n) a, Bit#(n) b);
    UInt#(n) a_uint = unpack(a);
    UInt#(n) b_uint = unpack(b);
    UInt#(TAdd#(n,1)) product_uint = zeroExtend(a_uint) + zeroExtend(b_uint);
    return pack( product_uint );
endfunction
// function Bit#(TAdd())

// unsigned shr
function Bit#(n) shr( Bit#(n) p, Integer a );
    Int#(n) tmp = unpack(p);
    return pack( tmp >> a );
endfunction


// Multiplication by repeated addition
function Bit#(TAdd#(n,n)) multiply_by_adding( Bit#(n) a, Bit#(n) b );
    // TODO: Implement this function in Exercise 2
    Bit#(n) upper = 0;
    Bit#(n) lower = 0;
    Bit#(n) tmp = 0;
    Bit#(TAdd#(n,1)) tmp_sum = 0;
    
    for (Integer i = 0; i < valueOf(n); i = i + 1)begin
        tmp = b[i] == 0 ? 0 : a;
        tmp_sum = add_unsigned(tmp,upper);
        lower[i] = tmp_sum[0];
        upper = tmp_sum[valueOf(n):1];
    end

    return {upper,lower};
//    return 0;
endfunction


// Multiplier Interface
interface Multiplier#( numeric type n );
    method Bool start_ready();
    method Action start( Bit#(n) a, Bit#(n) b );
    method Bool result_ready();
    method ActionValue#(Bit#(TAdd#(n,n))) result();
endinterface



// Folded multiplier by repeated addition
module mkFoldedMultiplier( Multiplier#(n) );
    // You can use these registers or create your own if you want
    Reg#(Bit#(n)) a <- mkRegU();
    Reg#(Bit#(n)) b <- mkRegU();
    Reg#(Bit#(n)) prod <- mkRegU();
    Reg#(Bit#(n)) tp <- mkRegU();
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)+1) );

    rule mulStep( i < fromInteger(valueOf(n)));
        // TODO: Implement this in Exercise 4
        Bit#(n) m = (a[i] == 0)? 0 : b;
        Bit#(TAdd#(n,1)) sum = add_unsigned(m, tp);
        prod[i] <= sum[0];
        tp <= sum[valueOf(n) : 1];
        i <= i + 1;
    endrule

    method Bool start_ready();
        // TODO: Implement this in Exercise 4
        return (i == fromInteger(valueOf(n) + 1));
    endmethod

    method Action start( Bit#(n) aIn, Bit#(n) bIn );
        // TODO: Implement this in Exercise 4
        a <= aIn;
        b <= bIn;
        i <= 0;
        prod <= 0;
        tp <= 0;
    endmethod

    method Bool result_ready();
        // TODO: Implement this in Exercise 4
        return (i >= fromInteger(valueOf(n)));
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        // TODO: Implement this in Exercise 4
        i <= i + 1;    
        return {tp,prod};
    endmethod
endmodule

// Booth Multiplier
module mkBoothMultiplier( Multiplier#(n) );
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) m_neg <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) m_pos <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) p <- mkRegU;
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)+1) );

    rule mul_step(i < fromInteger(valueOf(n)));
        // TODO: Implement this in Exercise 6
        let pr = p[1:0];
        let tmp = p;
        if (pr == 2'b01) begin
            tmp = tmp + m_pos;
        end
        else if (pr == 2'b10) begin
            tmp = tmp + m_neg;
        end
        p <= shr(tmp,1);
        i <= i + 1;
    endrule

    method Bool start_ready();
        // TODO: Implement this in Exercise 6
        return (i == fromInteger(valueOf(n) + 1));
    endmethod

    method Action start( Bit#(n) m, Bit#(n) r );
        // TODO: Implement this in Exercise 6
        m_pos <= {(m),0};
        m_neg <= {(-m),0};
        p <= {0,r,1'b0};
        i <= 0;
    endmethod

    method Bool result_ready();
        // TODO: Implement this in Exercise 6
        return (i >= fromInteger(valueOf(n)));
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        // TODO: Implement this in Exercise 6
        i <= i + 1;
        return p[2*valueOf(n):1];
    endmethod
endmodule



// Radix-4 Booth Multiplier
module mkBoothMultiplierRadix4( Multiplier#(n) );
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) m_neg <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) m_pos <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) p <- mkRegU;
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)/2+1) );

    rule mul_step( i < fromInteger(valueOf(n)/2));
        // TODO: Implement this in Exercise 8
        let pr = p[2:0];
        let tmp = p;

        if (pr == 3'b001 || pr == 3'b010 ) begin
            tmp = tmp + m_pos;
        end
        else if (pr == 3'b101 || pr == 3'b110) begin
            tmp = tmp + m_neg;
        end
        else if (pr == 3'b100)begin 
            tmp = tmp +  (m_neg << 1);
        end
        else if (pr == 3'b011)begin 
            tmp = tmp +  (m_pos << 1);
        end

        p <= shr(tmp,2);
        i <= i + 1;
    endrule

    method Bool start_ready();
        // TODO: Implement this in Exercise 8
        return (i == fromInteger(valueOf(n)/2 + 1));
    endmethod

    method Action start( Bit#(n) m, Bit#(n) r );
        // TODO: Implement this in Exercise 8
        m_pos <= {msb(m),m,0};
        m_neg <= {msb(-m),-m,0};
        i <= 0;
        p <= {0,r,1'b0};
    endmethod

    method Bool result_ready();
        // TODO: Implement this in Exercise 8
        return (i >= fromInteger(valueOf(n)/2));
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        // TODO: Implement this in Exercise 8
        i <= i+1;
        return p[valueOf(n)*2:1];
    endmethod
endmodule