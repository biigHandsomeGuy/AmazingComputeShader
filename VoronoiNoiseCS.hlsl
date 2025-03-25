RWTexture2D<float4> PerlinTexture : register(u0); // UAV Ŀ������
cbuffer CB : register(b0)
{
    float3 NoiseScale; // ��������ϸ�� (�Ŵ���������)
    float time;
}

float Hash(float2 p)
{
    return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453123);
}

float2 Random(float2 p)
{
    return float2(Hash(p), Hash(p + 1.2345));
}


[numthreads(8, 8, 1)]
void main(uint3 id : SV_DispatchThreadID)
{
    int2 dims;
    PerlinTexture.GetDimensions(dims.x, dims.y);

    
    // ���㵱ǰ���ص� UV ���꣨��һ����
    float2 uv = float2(id.xy) / float2(dims);

    float m = 0;
    float minDist = 100;
    float cellIndex = 0;
    for (int i = 0; i < 10; i++)
    {
        float2 n = Random(float2(i + 1, i + 1));
        float2 p = n + sin(time + i * 0.5) * 0.2;
        float d = length(uv - p);

        if (d < minDist)
        {
            minDist = d;
            cellIndex = i;
        }
    }

    PerlinTexture[id.xy] = float4(cellIndex.xxx/10, 1);
}
