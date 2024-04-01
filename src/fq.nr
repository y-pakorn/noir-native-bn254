use dep::std::{bigint::Bn254Fq, ops::{Add, Sub, Mul, Div}, cmp::Eq};

struct Fq {
    inner: Bn254Fq,
}

impl Add for Fq { 
    fn add(self: Self, other: Fq) -> Fq {
        Fq {
            inner: self.inner + other.inner
        }
    }
}

impl Sub for Fq { 
    fn sub(self: Self, other: Fq) -> Fq {
        Fq {
            inner: self.inner - other.inner
        }
    }
}

impl Mul for Fq { 
    fn mul(self: Self, other: Fq) -> Fq {
        Fq {
            inner: self.inner * other.inner
        }

    }
}

impl Div for Fq { 
    fn div(self: Self, other: Fq) -> Fq {
        Fq {
            inner: self.inner / other.inner
        }
    }
}

impl Eq for Fq {
    fn eq(self: Self, other: Fq) -> bool {
        self.inner == other.inner
    }
}

impl Fq {
    /// Create a new Fq from a little endian byte array.
    fn from_bytes(bytes: [u8]) -> Self {
        Fq { inner: Bn254Fq::from_le_bytes(bytes) }
    }

    /// Convert this Fq to a little endian byte array.
    fn to_bytes(self) -> [u8] {
        self.inner.to_le_bytes()
    }

    /// Constant zero.
    fn zero() -> Self {
        Fq::from_bytes(
            [
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        ]
        )
    }

    /// Constant one.
    fn one() -> Self {
        Fq::from_bytes(
            [
            0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        ]
        )
    }

    /// Returns true if this element is zero.
    fn is_zero(self: Self) -> bool {
        self == Fq::zero()
    }

    /// Returns true if this element is one.
    fn is_one(self: Self) -> bool {
        self == Fq::one()
    }

    /// Returns self + self.
    fn double(self: Self) -> Self {
        self + self
    }

    /// Returns self * self.
    fn square(self: Self) -> Self {
        self * self
    }

    /// Returns self ^ by. By is a little-endian bytes array.
    fn pow(self: Self, by: [u8]) -> Self {
        let mut tmp = self;
        let mut result = Fq::one();
        for i in 0..by.len() {
            let mut byte = by[i];
            for j in 0..8 {
                if byte & 1 == 1 {
                    result = result * self;
                }
                byte >>= 1;
                tmp = tmp.square();
            }
        }
        result
    }

    unconstrained fn pow_unc(self: Self, by: [u8]) -> Self {
        self.pow(by)
    }

    /// Returns the multiplicative inverse of this field element using Euler's theorem, if it is non-zero.
    fn inverse(self: Self) -> Self {
        assert(!self.is_zero());

        let inversed = self.pow_unc(
            [
            0x45, 0xFD, 0x7C, 0xD8, 0x16, 0x8C, 0x20, 0x3C, 0x8d, 0xca, 0x71, 0x68, 0x91, 0x6a, 0x81, 0x97,
            0x5d, 0x58, 0x81, 0x81, 0xb6, 0x45, 0x50, 0xb8, 0x29, 0xa0, 0x31, 0xe1, 0x72, 0x4e, 0x64, 0x30
        ]
        );
        assert(self * inversed == Fq::one());

        inversed
    }
}
