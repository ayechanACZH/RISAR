Texture2D texWAVE;
Texture2D texMASK;
SamplerState s0:IMMUTABLE {Filter=MIN_MAG_MIP_POINT;AddressU=CLAMP;AddressV=CLAMP;};

cbuffer cbControls : register( b0 )
{
    float4x4 tVP : VIEWPROJECTION;
    float4x4 tW : WORLD;
	
    //float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
    //float4 Color <bool color=true;> = { 1.0f,1.0f,1.0f,1.0f };
   // float4x4 tTex <string uiname="Texture Transform";>;
    //float4x4 tColor <string uiname="Color Transform";>;
	
};

struct VS_IN
{
    float4 PosO : POSITION;
    float4 TexCd : TEXCOORD0;
};

struct VS_OUT
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

VS_OUT VS(VS_IN In)
{
    VS_OUT Out=(VS_OUT)0;
    Out.PosWVP=mul(In.PosO,mul(tW,tVP));
    Out.TexCd=In.TexCd;
    return Out;
}

float2 R:TARGETSIZE;
float Amplitude =1;

float4 PS(VS_OUT In):SV_Target
{
	float2 uv=In.TexCd.xy+.0;
    float4 c=texWAVE.Sample(s0,uv);
	c.rgb=c.r*0.5*Amplitude+.5;
	c.rgb=max(0.001,c.rgb);
	c.a=1;
    return c;
}


technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}
