key_T = NamedTuple{(:num, :tr, :allpaths),Tuple{Int64,Bool,Bool}}
reference_csv = Dict{key_T,String}()

# --- plane group 1 ---
reference_csv[(num=1, tr=false, allpaths=true)] = """
Wyckoff pos.|1a(1)|1a(1)
Band-Rep.|A↑G(1)|Aˢ↑G(1)
Decomposable|false|false
X:(1/2,0)|X₁(1)|Xˢ₂(1)
Y:(0,1/2)|Y₁(1)|Yˢ₂(1)
M:(1/2,1/2)|M₁(1)|Mˢ₂(1)
Γ:(0,0)|Γ₁(1)|Γˢ₂(1)
Ω:(u,v)|Ω₁(1)|Ωˢ₂(1)
"""

# --- plane group 16 ---
reference_csv[(num=16, tr=false, allpaths=false)] = """
Wyckoff pos.|1a(6)|1a(6)|1a(6)|1a(6)|1a(6)|1a(6)|2b(3)|2b(3)|2b(3)|3c(2)|3c(2)|1a(6)|1a(6)|1a(6)|1a(6)|1a(6)|1a(6)|2b(3)|2b(3)|2b(3)|3c(2)|3c(2)
Band-Rep.|A↑G(1)|B↑G(1)|¹E₁↑G(1)|¹E₂↑G(1)|²E₁↑G(1)|²E₂↑G(1)|A₁↑G(2)|¹E↑G(2)|²E↑G(2)|A↑G(3)|B↑G(3)|¹Eˢ₁↑G(1)|¹Eˢ₂↑G(1)|¹Eˢ₃↑G(1)|²Eˢ₁↑G(1)|²Eˢ₂↑G(1)|²Eˢ₃↑G(1)|¹Eˢ↑G(2)|²Eˢ↑G(2)|Eˢ↑G(2)|¹Eˢ↑G(3)|²Eˢ↑G(3)
Decomposable|false|false|false|false|false|false|true|true|true|true|true|false|false|false|false|false|false|true|true|true|true|true
Γ:(0,0)|Γ₁(1)|Γ₂(1)|Γ₃(1)|Γ₄(1)|Γ₅(1)|Γ₆(1)|Γ₁(1)⊕Γ₂(1)|Γ₃(1)⊕Γ₄(1)|Γ₅(1)⊕Γ₆(1)|Γ₁(1)⊕Γ₃(1)⊕Γ₅(1)|Γ₂(1)⊕Γ₄(1)⊕Γ₆(1)|Γˢ₇(1)|Γˢ₉(1)|Γˢ₁₁(1)|Γˢ₈(1)|Γˢ₁₂(1)|Γˢ₁₀(1)|Γˢ₁₁(1)⊕Γˢ₁₂(1)|Γˢ₉(1)⊕Γˢ₁₀(1)|Γˢ₇(1)⊕Γˢ₈(1)|Γˢ₇(1)⊕Γˢ₉(1)⊕Γˢ₁₁(1)|Γˢ₈(1)⊕Γˢ₁₀(1)⊕Γˢ₁₂(1)
K:(1/3,1/3)|K₁(1)|K₁(1)|K₂(1)|K₂(1)|K₃(1)|K₃(1)|K₂(1)⊕K₃(1)|K₁(1)⊕K₃(1)|K₁(1)⊕K₂(1)|K₁(1)⊕K₂(1)⊕K₃(1)|K₁(1)⊕K₂(1)⊕K₃(1)|Kˢ₄(1)|Kˢ₅(1)|Kˢ₆(1)|Kˢ₄(1)|Kˢ₆(1)|Kˢ₅(1)|Kˢ₄(1)⊕Kˢ₅(1)|Kˢ₄(1)⊕Kˢ₆(1)|Kˢ₅(1)⊕Kˢ₆(1)|Kˢ₄(1)⊕Kˢ₅(1)⊕Kˢ₆(1)|Kˢ₄(1)⊕Kˢ₅(1)⊕Kˢ₆(1)
M:(1/2,0)|M₁(1)|M₂(1)|M₁(1)|M₂(1)|M₁(1)|M₂(1)|M₁(1)⊕M₂(1)|M₁(1)⊕M₂(1)|M₁(1)⊕M₂(1)|M₁(1)⊕2M₂(1)|2M₁(1)⊕M₂(1)|Mˢ₃(1)|Mˢ₃(1)|Mˢ₃(1)|Mˢ₄(1)|Mˢ₄(1)|Mˢ₄(1)|Mˢ₃(1)⊕Mˢ₄(1)|Mˢ₃(1)⊕Mˢ₄(1)|Mˢ₃(1)⊕Mˢ₄(1)|Mˢ₃(1)⊕2Mˢ₄(1)|2Mˢ₃(1)⊕Mˢ₄(1)
"""

reference_csv[(num=16, tr=false, allpaths=true)] = """
Wyckoff pos.|1a(6)|1a(6)|1a(6)|1a(6)|1a(6)|1a(6)|2b(3)|2b(3)|2b(3)|3c(2)|3c(2)|1a(6)|1a(6)|1a(6)|1a(6)|1a(6)|1a(6)|2b(3)|2b(3)|2b(3)|3c(2)|3c(2)
Band-Rep.|A↑G(1)|B↑G(1)|¹E₁↑G(1)|¹E₂↑G(1)|²E₁↑G(1)|²E₂↑G(1)|A₁↑G(2)|¹E↑G(2)|²E↑G(2)|A↑G(3)|B↑G(3)|¹Eˢ₁↑G(1)|¹Eˢ₂↑G(1)|¹Eˢ₃↑G(1)|²Eˢ₁↑G(1)|²Eˢ₂↑G(1)|²Eˢ₃↑G(1)|¹Eˢ↑G(2)|²Eˢ↑G(2)|Eˢ↑G(2)|¹Eˢ↑G(3)|²Eˢ↑G(3)
Decomposable|false|false|false|false|false|false|true|true|true|true|true|false|false|false|false|false|false|true|true|true|true|true
Γ:(0,0)|Γ₁(1)|Γ₂(1)|Γ₃(1)|Γ₄(1)|Γ₅(1)|Γ₆(1)|Γ₁(1)⊕Γ₂(1)|Γ₃(1)⊕Γ₄(1)|Γ₅(1)⊕Γ₆(1)|Γ₁(1)⊕Γ₃(1)⊕Γ₅(1)|Γ₂(1)⊕Γ₄(1)⊕Γ₆(1)|Γˢ₇(1)|Γˢ₉(1)|Γˢ₁₁(1)|Γˢ₈(1)|Γˢ₁₂(1)|Γˢ₁₀(1)|Γˢ₁₁(1)⊕Γˢ₁₂(1)|Γˢ₉(1)⊕Γˢ₁₀(1)|Γˢ₇(1)⊕Γˢ₈(1)|Γˢ₇(1)⊕Γˢ₉(1)⊕Γˢ₁₁(1)|Γˢ₈(1)⊕Γˢ₁₀(1)⊕Γˢ₁₂(1)
K:(1/3,1/3)|K₁(1)|K₁(1)|K₂(1)|K₂(1)|K₃(1)|K₃(1)|K₂(1)⊕K₃(1)|K₁(1)⊕K₃(1)|K₁(1)⊕K₂(1)|K₁(1)⊕K₂(1)⊕K₃(1)|K₁(1)⊕K₂(1)⊕K₃(1)|Kˢ₄(1)|Kˢ₅(1)|Kˢ₆(1)|Kˢ₄(1)|Kˢ₆(1)|Kˢ₅(1)|Kˢ₄(1)⊕Kˢ₅(1)|Kˢ₄(1)⊕Kˢ₆(1)|Kˢ₅(1)⊕Kˢ₆(1)|Kˢ₄(1)⊕Kˢ₅(1)⊕Kˢ₆(1)|Kˢ₄(1)⊕Kˢ₅(1)⊕Kˢ₆(1)
M:(1/2,0)|M₁(1)|M₂(1)|M₁(1)|M₂(1)|M₁(1)|M₂(1)|M₁(1)⊕M₂(1)|M₁(1)⊕M₂(1)|M₁(1)⊕M₂(1)|M₁(1)⊕2M₂(1)|2M₁(1)⊕M₂(1)|Mˢ₃(1)|Mˢ₃(1)|Mˢ₃(1)|Mˢ₄(1)|Mˢ₄(1)|Mˢ₄(1)|Mˢ₃(1)⊕Mˢ₄(1)|Mˢ₃(1)⊕Mˢ₄(1)|Mˢ₃(1)⊕Mˢ₄(1)|Mˢ₃(1)⊕2Mˢ₄(1)|2Mˢ₃(1)⊕Mˢ₄(1)
Ω:(u,v)|Ω₁(1)|Ω₁(1)|Ω₁(1)|Ω₁(1)|Ω₁(1)|Ω₁(1)|2Ω₁(1)|2Ω₁(1)|2Ω₁(1)|3Ω₁(1)|3Ω₁(1)|Ωˢ₂(1)|Ωˢ₂(1)|Ωˢ₂(1)|Ωˢ₂(1)|Ωˢ₂(1)|Ωˢ₂(1)|2Ωˢ₂(1)|2Ωˢ₂(1)|2Ωˢ₂(1)|3Ωˢ₂(1)|3Ωˢ₂(1)
Λ:(u,u)|Λ₁(1)|Λ₁(1)|Λ₁(1)|Λ₁(1)|Λ₁(1)|Λ₁(1)|2Λ₁(1)|2Λ₁(1)|2Λ₁(1)|3Λ₁(1)|3Λ₁(1)|Λˢ₂(1)|Λˢ₂(1)|Λˢ₂(1)|Λˢ₂(1)|Λˢ₂(1)|Λˢ₂(1)|2Λˢ₂(1)|2Λˢ₂(1)|2Λˢ₂(1)|3Λˢ₂(1)|3Λˢ₂(1)
Σ:(u,0)|Σ₁(1)|Σ₁(1)|Σ₁(1)|Σ₁(1)|Σ₁(1)|Σ₁(1)|2Σ₁(1)|2Σ₁(1)|2Σ₁(1)|3Σ₁(1)|3Σ₁(1)|Σˢ₂(1)|Σˢ₂(1)|Σˢ₂(1)|Σˢ₂(1)|Σˢ₂(1)|Σˢ₂(1)|2Σˢ₂(1)|2Σˢ₂(1)|2Σˢ₂(1)|3Σˢ₂(1)|3Σˢ₂(1)
"""

reference_csv[(num=16, tr=true, allpaths=false)] = """
Wyckoff pos.|1a(6)|1a(6)|1a(6)|1a(6)|2b(3)|2b(3)|3c(2)|3c(2)|1a(6)|1a(6)|1a(6)|2b(3)|2b(3)|3c(2)
Band-Rep.|A↑G(1)|B↑G(1)|¹E₁²E₁↑G(2)|¹E₂²E₂↑G(2)|A₁↑G(2)|¹E²E↑G(4)|A↑G(3)|B↑G(3)|¹Eˢ₁²Eˢ₁↑G(2)|¹Eˢ₂²Eˢ₂↑G(2)|¹Eˢ₃²Eˢ₃↑G(2)|¹Eˢ²Eˢ↑G(4)|EˢEˢ↑G(4)|¹Eˢ²Eˢ↑G(6)
Decomposable|false|false|false|false|false|true|true|true|false|false|false|true|true|true
Γ:(0,0)|Γ₁(1)|Γ₂(1)|Γ₃Γ₅(2)|Γ₄Γ₆(2)|Γ₁(1)⊕Γ₂(1)|Γ₃Γ₅(2)⊕Γ₄Γ₆(2)|Γ₁(1)⊕Γ₃Γ₅(2)|Γ₂(1)⊕Γ₄Γ₆(2)|Γˢ₇Γˢ₈(2)|Γˢ₁₂Γˢ₉(2)|Γˢ₁₀Γˢ₁₁(2)|Γˢ₁₀Γˢ₁₁(2)⊕Γˢ₁₂Γˢ₉(2)|2Γˢ₇Γˢ₈(2)|Γˢ₇Γˢ₈(2)⊕Γˢ₁₀Γˢ₁₁(2)⊕Γˢ₁₂Γˢ₉(2)
K:(1/3,1/3)|K₁(1)|K₁(1)|K₂K₃(2)|K₂K₃(2)|K₂K₃(2)|2K₁(1)⊕K₂K₃(2)|K₁(1)⊕K₂K₃(2)|K₁(1)⊕K₂K₃(2)|2Kˢ₄(1)|Kˢ₅Kˢ₆(2)|Kˢ₅Kˢ₆(2)|2Kˢ₄(1)⊕Kˢ₅Kˢ₆(2)|2Kˢ₅Kˢ₆(2)|2Kˢ₄(1)⊕2Kˢ₅Kˢ₆(2)
M:(1/2,0)|M₁(1)|M₂(1)|2M₁(1)|2M₂(1)|M₁(1)⊕M₂(1)|2M₁(1)⊕2M₂(1)|M₁(1)⊕2M₂(1)|2M₁(1)⊕M₂(1)|Mˢ₃Mˢ₄(2)|Mˢ₃Mˢ₄(2)|Mˢ₃Mˢ₄(2)|2Mˢ₃Mˢ₄(2)|2Mˢ₃Mˢ₄(2)|3Mˢ₃Mˢ₄(2)
"""

reference_csv[(num=16, tr=true, allpaths=true)] = """
Wyckoff pos.|1a(6)|1a(6)|1a(6)|1a(6)|2b(3)|2b(3)|3c(2)|3c(2)|1a(6)|1a(6)|1a(6)|2b(3)|2b(3)|3c(2)
Band-Rep.|A↑G(1)|B↑G(1)|¹E₁²E₁↑G(2)|¹E₂²E₂↑G(2)|A₁↑G(2)|¹E²E↑G(4)|A↑G(3)|B↑G(3)|¹Eˢ₁²Eˢ₁↑G(2)|¹Eˢ₂²Eˢ₂↑G(2)|¹Eˢ₃²Eˢ₃↑G(2)|¹Eˢ²Eˢ↑G(4)|EˢEˢ↑G(4)|¹Eˢ²Eˢ↑G(6)
Decomposable|false|false|false|false|false|true|true|true|false|false|false|true|true|true
Γ:(0,0)|Γ₁(1)|Γ₂(1)|Γ₃Γ₅(2)|Γ₄Γ₆(2)|Γ₁(1)⊕Γ₂(1)|Γ₃Γ₅(2)⊕Γ₄Γ₆(2)|Γ₁(1)⊕Γ₃Γ₅(2)|Γ₂(1)⊕Γ₄Γ₆(2)|Γˢ₇Γˢ₈(2)|Γˢ₁₂Γˢ₉(2)|Γˢ₁₀Γˢ₁₁(2)|Γˢ₁₀Γˢ₁₁(2)⊕Γˢ₁₂Γˢ₉(2)|2Γˢ₇Γˢ₈(2)|Γˢ₇Γˢ₈(2)⊕Γˢ₁₀Γˢ₁₁(2)⊕Γˢ₁₂Γˢ₉(2)
K:(1/3,1/3)|K₁(1)|K₁(1)|K₂K₃(2)|K₂K₃(2)|K₂K₃(2)|2K₁(1)⊕K₂K₃(2)|K₁(1)⊕K₂K₃(2)|K₁(1)⊕K₂K₃(2)|2Kˢ₄(1)|Kˢ₅Kˢ₆(2)|Kˢ₅Kˢ₆(2)|2Kˢ₄(1)⊕Kˢ₅Kˢ₆(2)|2Kˢ₅Kˢ₆(2)|2Kˢ₄(1)⊕2Kˢ₅Kˢ₆(2)
M:(1/2,0)|M₁(1)|M₂(1)|2M₁(1)|2M₂(1)|M₁(1)⊕M₂(1)|2M₁(1)⊕2M₂(1)|M₁(1)⊕2M₂(1)|2M₁(1)⊕M₂(1)|Mˢ₃Mˢ₄(2)|Mˢ₃Mˢ₄(2)|Mˢ₃Mˢ₄(2)|2Mˢ₃Mˢ₄(2)|2Mˢ₃Mˢ₄(2)|3Mˢ₃Mˢ₄(2)
Ω:(u,v)|Ω₁(1)|Ω₁(1)|2Ω₁(1)|2Ω₁(1)|2Ω₁(1)|4Ω₁(1)|3Ω₁(1)|3Ω₁(1)|2Ωˢ₂(1)|2Ωˢ₂(1)|2Ωˢ₂(1)|4Ωˢ₂(1)|4Ωˢ₂(1)|6Ωˢ₂(1)
Λ:(u,u)|Λ₁(1)|Λ₁(1)|2Λ₁(1)|2Λ₁(1)|2Λ₁(1)|4Λ₁(1)|3Λ₁(1)|3Λ₁(1)|2Λˢ₂(1)|2Λˢ₂(1)|2Λˢ₂(1)|4Λˢ₂(1)|4Λˢ₂(1)|6Λˢ₂(1)
Σ:(u,0)|Σ₁(1)|Σ₁(1)|2Σ₁(1)|2Σ₁(1)|2Σ₁(1)|4Σ₁(1)|3Σ₁(1)|3Σ₁(1)|2Σˢ₂(1)|2Σˢ₂(1)|2Σˢ₂(1)|4Σˢ₂(1)|4Σˢ₂(1)|6Σˢ₂(1)
"""

# --- plane group 17 ---
reference_csv[(num=17, tr=false, allpaths=false)] = """
Wyckoff pos.|1a(6mm)|1a(6mm)|1a(6mm)|1a(6mm)|1a(6mm)|1a(6mm)|2b(3m)|2b(3m)|2b(3m)|3c(mm2)|3c(mm2)|3c(mm2)|3c(mm2)|1a(6mm)|1a(6mm)|1a(6mm)|2b(3m)|2b(3m)|2b(3m)
Band-Rep.|A₁↑G(1)|A₂↑G(1)|B₁↑G(1)|B₂↑G(1)|E₁↑G(2)|E₂↑G(2)|A₁↑G(2)|A₂↑G(2)|E↑G(4)|A₁↑G(3)|A₂↑G(3)|B₁↑G(3)|B₂↑G(3)|Eˢ₁↑G(2)|Eˢ₂↑G(2)|Eˢ₃↑G(2)|¹Eˢ↑G(2)|²Eˢ↑G(2)|Eˢ₁↑G(4)
Decomposable|false|false|false|false|false|false|false|false|true|true|true|true|true|false|false|false|false|false|true
Γ:(0,0,0)|Γ₁(1)|Γ₂(1)|Γ₄(1)|Γ₃(1)|Γ₆(2)|Γ₅(2)|Γ₁(1)⊕Γ₄(1)|Γ₂(1)⊕Γ₃(1)|Γ₅(2)⊕Γ₆(2)|Γ₁(1)⊕Γ₅(2)|Γ₂(1)⊕Γ₅(2)|Γ₃(1)⊕Γ₆(2)|Γ₄(1)⊕Γ₆(2)|Γˢ₉(2)|Γˢ₈(2)|Γˢ₇(2)|Γˢ₇(2)|Γˢ₇(2)|Γˢ₈(2)⊕Γˢ₉(2)
K:(1/3,1/3)|K₁(1)|K₂(1)|K₂(1)|K₁(1)|K₃(2)|K₃(2)|K₃(2)|K₃(2)|K₁(1)⊕K₂(1)⊕K₃(2)|K₁(1)⊕K₃(2)|K₂(1)⊕K₃(2)|K₁(1)⊕K₃(2)|K₂(1)⊕K₃(2)|Kˢ₆(2)|Kˢ₆(2)|Kˢ₄(1)⊕Kˢ₅(1)|Kˢ₆(2)|Kˢ₆(2)|Kˢ₄(1)⊕Kˢ₅(1)⊕Kˢ₆(2)
M:(1/2,0)|M₁(1)|M₂(1)|M₄(1)|M₃(1)|M₃(1)⊕M₄(1)|M₁(1)⊕M₂(1)|M₁(1)⊕M₄(1)|M₂(1)⊕M₃(1)|M₁(1)⊕M₂(1)⊕M₃(1)⊕M₄(1)|M₁(1)⊕M₃(1)⊕M₄(1)|M₂(1)⊕M₃(1)⊕M₄(1)|M₁(1)⊕M₂(1)⊕M₃(1)|M₁(1)⊕M₂(1)⊕M₄(1)|Mˢ₅(2)|Mˢ₅(2)|Mˢ₅(2)|Mˢ₅(2)|Mˢ₅(2)|2Mˢ₅(2)
"""

reference_csv[(num=17, tr=false, allpaths=true)] = """
Wyckoff pos.|1a(6mm)|1a(6mm)|1a(6mm)|1a(6mm)|1a(6mm)|1a(6mm)|2b(3m)|2b(3m)|2b(3m)|3c(mm2)|3c(mm2)|3c(mm2)|3c(mm2)|1a(6mm)|1a(6mm)|1a(6mm)|2b(3m)|2b(3m)|2b(3m)
Band-Rep.|A₁↑G(1)|A₂↑G(1)|B₁↑G(1)|B₂↑G(1)|E₁↑G(2)|E₂↑G(2)|A₁↑G(2)|A₂↑G(2)|E↑G(4)|A₁↑G(3)|A₂↑G(3)|B₁↑G(3)|B₂↑G(3)|Eˢ₁↑G(2)|Eˢ₂↑G(2)|Eˢ₃↑G(2)|¹Eˢ↑G(2)|²Eˢ↑G(2)|Eˢ₁↑G(4)
Decomposable|false|false|false|false|false|false|false|false|true|true|true|true|true|false|false|false|false|false|true
Γ:(0,0,0)|Γ₁(1)|Γ₂(1)|Γ₄(1)|Γ₃(1)|Γ₆(2)|Γ₅(2)|Γ₁(1)⊕Γ₄(1)|Γ₂(1)⊕Γ₃(1)|Γ₅(2)⊕Γ₆(2)|Γ₁(1)⊕Γ₅(2)|Γ₂(1)⊕Γ₅(2)|Γ₃(1)⊕Γ₆(2)|Γ₄(1)⊕Γ₆(2)|Γˢ₉(2)|Γˢ₈(2)|Γˢ₇(2)|Γˢ₇(2)|Γˢ₇(2)|Γˢ₈(2)⊕Γˢ₉(2)
K:(1/3,1/3)|K₁(1)|K₂(1)|K₂(1)|K₁(1)|K₃(2)|K₃(2)|K₃(2)|K₃(2)|K₁(1)⊕K₂(1)⊕K₃(2)|K₁(1)⊕K₃(2)|K₂(1)⊕K₃(2)|K₁(1)⊕K₃(2)|K₂(1)⊕K₃(2)|Kˢ₆(2)|Kˢ₆(2)|Kˢ₄(1)⊕Kˢ₅(1)|Kˢ₆(2)|Kˢ₆(2)|Kˢ₄(1)⊕Kˢ₅(1)⊕Kˢ₆(2)
M:(1/2,0)|M₁(1)|M₂(1)|M₄(1)|M₃(1)|M₃(1)⊕M₄(1)|M₁(1)⊕M₂(1)|M₁(1)⊕M₄(1)|M₂(1)⊕M₃(1)|M₁(1)⊕M₂(1)⊕M₃(1)⊕M₄(1)|M₁(1)⊕M₃(1)⊕M₄(1)|M₂(1)⊕M₃(1)⊕M₄(1)|M₁(1)⊕M₂(1)⊕M₃(1)|M₁(1)⊕M₂(1)⊕M₄(1)|Mˢ₅(2)|Mˢ₅(2)|Mˢ₅(2)|Mˢ₅(2)|Mˢ₅(2)|2Mˢ₅(2)
Λ:(u,u)|Λ₁(1)|Λ₂(1)|Λ₂(1)|Λ₁(1)|Λ₁(1)⊕Λ₂(1)|Λ₁(1)⊕Λ₂(1)|Λ₁(1)⊕Λ₂(1)|Λ₁(1)⊕Λ₂(1)|2Λ₁(1)⊕2Λ₂(1)|2Λ₁(1)⊕Λ₂(1)|Λ₁(1)⊕2Λ₂(1)|2Λ₁(1)⊕Λ₂(1)|Λ₁(1)⊕2Λ₂(1)|Λˢ₃(1)⊕Λˢ₄(1)|Λˢ₃(1)⊕Λˢ₄(1)|Λˢ₃(1)⊕Λˢ₄(1)|Λˢ₃(1)⊕Λˢ₄(1)|Λˢ₃(1)⊕Λˢ₄(1)|2Λˢ₃(1)⊕2Λˢ₄(1)
Σ:(u,0)|Σ₁(1)|Σ₂(1)|Σ₁(1)|Σ₂(1)|Σ₁(1)⊕Σ₂(1)|Σ₁(1)⊕Σ₂(1)|2Σ₁(1)|2Σ₂(1)|2Σ₁(1)⊕2Σ₂(1)|2Σ₁(1)⊕Σ₂(1)|Σ₁(1)⊕2Σ₂(1)|Σ₁(1)⊕2Σ₂(1)|2Σ₁(1)⊕Σ₂(1)|Σˢ₃(1)⊕Σˢ₄(1)|Σˢ₃(1)⊕Σˢ₄(1)|Σˢ₃(1)⊕Σˢ₄(1)|Σˢ₃(1)⊕Σˢ₄(1)|Σˢ₃(1)⊕Σˢ₄(1)|2Σˢ₃(1)⊕2Σˢ₄(1)
Ω:(u,v)|Ω₁(1)|Ω₁(1)|Ω₁(1)|Ω₁(1)|2Ω₁(1)|2Ω₁(1)|2Ω₁(1)|2Ω₁(1)|4Ω₁(1)|3Ω₁(1)|3Ω₁(1)|3Ω₁(1)|3Ω₁(1)|2Ωˢ₂(1)|2Ωˢ₂(1)|2Ωˢ₂(1)|2Ωˢ₂(1)|2Ωˢ₂(1)|4Ωˢ₂(1)
"""

reference_csv[(num=17, tr=true, allpaths=false)] = """
Wyckoff pos.|1a(6mm)|1a(6mm)|1a(6mm)|1a(6mm)|1a(6mm)|1a(6mm)|2b(3m)|2b(3m)|2b(3m)|3c(mm2)|3c(mm2)|3c(mm2)|3c(mm2)|1a(6mm)|1a(6mm)|1a(6mm)|2b(3m)|2b(3m)|3c(mm2)
Band-Rep.|A₁↑G(1)|A₂↑G(1)|B₁↑G(1)|B₂↑G(1)|E₁↑G(2)|E₂↑G(2)|A₁↑G(2)|A₂↑G(2)|E↑G(4)|A₁↑G(3)|A₂↑G(3)|B₁↑G(3)|B₂↑G(3)|Eˢ₁↑G(2)|Eˢ₂↑G(2)|Eˢ₃↑G(2)|¹Eˢ²Eˢ↑G(4)|Eˢ₁↑G(4)|Eˢ↑G(6)
Decomposable|false|false|false|false|false|false|false|false|true|true|true|true|true|false|false|false|true|true|true
Γ:(0,0)|Γ₁(1)|Γ₂(1)|Γ₄(1)|Γ₃(1)|Γ₆(2)|Γ₅(2)|Γ₁(1)⊕Γ₄(1)|Γ₂(1)⊕Γ₃(1)|Γ₅(2)⊕Γ₆(2)|Γ₁(1)⊕Γ₅(2)|Γ₂(1)⊕Γ₅(2)|Γ₃(1)⊕Γ₆(2)|Γ₄(1)⊕Γ₆(2)|Γˢ₉(2)|Γˢ₈(2)|Γˢ₇(2)|2Γˢ₇(2)|Γˢ₈(2)⊕Γˢ₉(2)|Γˢ₇(2)⊕Γˢ₈(2)⊕Γˢ₉(2)
K:(1/3,1/3)|K₁(1)|K₂(1)|K₂(1)|K₁(1)|K₃(2)|K₃(2)|K₃(2)|K₃(2)|K₁(1)⊕K₂(1)⊕K₃(2)|K₁(1)⊕K₃(2)|K₂(1)⊕K₃(2)|K₁(1)⊕K₃(2)|K₂(1)⊕K₃(2)|Kˢ₆(2)|Kˢ₆(2)|Kˢ₄(1)⊕Kˢ₅(1)|2Kˢ₆(2)|Kˢ₄(1)⊕Kˢ₅(1)⊕Kˢ₆(2)|Kˢ₄(1)⊕Kˢ₅(1)⊕2Kˢ₆(2)
M:(1/2,0)|M₁(1)|M₂(1)|M₄(1)|M₃(1)|M₃(1)⊕M₄(1)|M₁(1)⊕M₂(1)|M₁(1)⊕M₄(1)|M₂(1)⊕M₃(1)|M₁(1)⊕M₂(1)⊕M₃(1)⊕M₄(1)|M₁(1)⊕M₃(1)⊕M₄(1)|M₂(1)⊕M₃(1)⊕M₄(1)|M₁(1)⊕M₂(1)⊕M₃(1)|M₁(1)⊕M₂(1)⊕M₄(1)|Mˢ₅(2)|Mˢ₅(2)|Mˢ₅(2)|2Mˢ₅(2)|2Mˢ₅(2)|3Mˢ₅(2)
"""

reference_csv[(num=17, tr=true, allpaths=true)] = """
Wyckoff pos.|1a(6mm)|1a(6mm)|1a(6mm)|1a(6mm)|1a(6mm)|1a(6mm)|2b(3m)|2b(3m)|2b(3m)|3c(mm2)|3c(mm2)|3c(mm2)|3c(mm2)|1a(6mm)|1a(6mm)|1a(6mm)|2b(3m)|2b(3m)|3c(mm2)
Band-Rep.|A₁↑G(1)|A₂↑G(1)|B₁↑G(1)|B₂↑G(1)|E₁↑G(2)|E₂↑G(2)|A₁↑G(2)|A₂↑G(2)|E↑G(4)|A₁↑G(3)|A₂↑G(3)|B₁↑G(3)|B₂↑G(3)|Eˢ₁↑G(2)|Eˢ₂↑G(2)|Eˢ₃↑G(2)|¹Eˢ²Eˢ↑G(4)|Eˢ₁↑G(4)|Eˢ↑G(6)
Decomposable|false|false|false|false|false|false|false|false|true|true|true|true|true|false|false|false|true|true|true
Γ:(0,0)|Γ₁(1)|Γ₂(1)|Γ₄(1)|Γ₃(1)|Γ₆(2)|Γ₅(2)|Γ₁(1)⊕Γ₄(1)|Γ₂(1)⊕Γ₃(1)|Γ₅(2)⊕Γ₆(2)|Γ₁(1)⊕Γ₅(2)|Γ₂(1)⊕Γ₅(2)|Γ₃(1)⊕Γ₆(2)|Γ₄(1)⊕Γ₆(2)|Γˢ₉(2)|Γˢ₈(2)|Γˢ₇(2)|2Γˢ₇(2)|Γˢ₈(2)⊕Γˢ₉(2)|Γˢ₇(2)⊕Γˢ₈(2)⊕Γˢ₉(2)
K:(1/3,1/3)|K₁(1)|K₂(1)|K₂(1)|K₁(1)|K₃(2)|K₃(2)|K₃(2)|K₃(2)|K₁(1)⊕K₂(1)⊕K₃(2)|K₁(1)⊕K₃(2)|K₂(1)⊕K₃(2)|K₁(1)⊕K₃(2)|K₂(1)⊕K₃(2)|Kˢ₆(2)|Kˢ₆(2)|Kˢ₄(1)⊕Kˢ₅(1)|2Kˢ₆(2)|Kˢ₄(1)⊕Kˢ₅(1)⊕Kˢ₆(2)|Kˢ₄(1)⊕Kˢ₅(1)⊕2Kˢ₆(2)
M:(1/2,0)|M₁(1)|M₂(1)|M₄(1)|M₃(1)|M₃(1)⊕M₄(1)|M₁(1)⊕M₂(1)|M₁(1)⊕M₄(1)|M₂(1)⊕M₃(1)|M₁(1)⊕M₂(1)⊕M₃(1)⊕M₄(1)|M₁(1)⊕M₃(1)⊕M₄(1)|M₂(1)⊕M₃(1)⊕M₄(1)|M₁(1)⊕M₂(1)⊕M₃(1)|M₁(1)⊕M₂(1)⊕M₄(1)|Mˢ₅(2)|Mˢ₅(2)|Mˢ₅(2)|2Mˢ₅(2)|2Mˢ₅(2)|3Mˢ₅(2)
Λ:(u,u)|Λ₁(1)|Λ₂(1)|Λ₂(1)|Λ₁(1)|Λ₁(1)⊕Λ₂(1)|Λ₁(1)⊕Λ₂(1)|Λ₁(1)⊕Λ₂(1)|Λ₁(1)⊕Λ₂(1)|2Λ₁(1)⊕2Λ₂(1)|2Λ₁(1)⊕Λ₂(1)|Λ₁(1)⊕2Λ₂(1)|2Λ₁(1)⊕Λ₂(1)|Λ₁(1)⊕2Λ₂(1)|Λˢ₃(1)⊕Λˢ₄(1)|Λˢ₃(1)⊕Λˢ₄(1)|Λˢ₃(1)⊕Λˢ₄(1)|2Λˢ₃(1)⊕2Λˢ₄(1)|2Λˢ₃(1)⊕2Λˢ₄(1)|3Λˢ₃(1)⊕3Λˢ₄(1)
Σ:(u,0)|Σ₁(1)|Σ₂(1)|Σ₁(1)|Σ₂(1)|Σ₁(1)⊕Σ₂(1)|Σ₁(1)⊕Σ₂(1)|2Σ₁(1)|2Σ₂(1)|2Σ₁(1)⊕2Σ₂(1)|2Σ₁(1)⊕Σ₂(1)|Σ₁(1)⊕2Σ₂(1)|Σ₁(1)⊕2Σ₂(1)|2Σ₁(1)⊕Σ₂(1)|Σˢ₃(1)⊕Σˢ₄(1)|Σˢ₃(1)⊕Σˢ₄(1)|Σˢ₃(1)⊕Σˢ₄(1)|2Σˢ₃(1)⊕2Σˢ₄(1)|2Σˢ₃(1)⊕2Σˢ₄(1)|3Σˢ₃(1)⊕3Σˢ₄(1)
Ω:(u,v)|Ω₁(1)|Ω₁(1)|Ω₁(1)|Ω₁(1)|2Ω₁(1)|2Ω₁(1)|2Ω₁(1)|2Ω₁(1)|4Ω₁(1)|3Ω₁(1)|3Ω₁(1)|3Ω₁(1)|3Ω₁(1)|2Ωˢ₂(1)|2Ωˢ₂(1)|2Ωˢ₂(1)|4Ωˢ₂(1)|4Ωˢ₂(1)|6Ωˢ₂(1)
"""