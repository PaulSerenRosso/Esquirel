using System.Collections;
using System.Collections.Generic;
using Entities;
using UnityEngine;
using UnityEngine.UI;

namespace Entities.FogOfWar
{
public class EntityFOWShowableLinker : MonoBehaviour
{
    public ParticleSystem[] particleSystems;
    public MeshRenderer[] meshRenderers;
    public Image[] images;
    public void LinkEntity(Entity entity)
    {
        for (int i = 0; i < particleSystems.Length; i++)
        {
            entity.particleSystemsToShow.Add(particleSystems[i]);
            entity.particleSystemsToShowAlpha.Add(1);
        }

        for (int i = 0; i < meshRenderers.Length; i++)
        {
            entity.meshRenderersToShow.Add(meshRenderers[i]);
            entity.meshRenderersToShowAlpha.Add(1);
        }

        for (int i = 0; i < images.Length; i++)
        {
            entity.imagesToShow.Add(images[i]);
            entity.imagesToShowAlpha.Add(1);
        }
    }
}
}
