RWTexture2D<float4> PerlinTexture : register(u0);
cbuffer CB : register(b0)
{
    float2 NoiseScale;
}

// Compute Shader ������
[numthreads(16, 16, 1)]
void main(uint3 id : SV_DispatchThreadID)
{
    int2 dims;
    PerlinTexture.GetDimensions(dims.x, dims.y);

    // ������ֵд��Ŀ������
    PerlinTexture[id.xy] = float4(1, 1, 1, 1);
}
