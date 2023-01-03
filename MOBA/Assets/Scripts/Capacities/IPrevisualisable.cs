using UnityEngine;

namespace Entities.Capacities
{
    public interface IPrevisualisable
    {
        public void EnableDrawing();

        public void DisableDrawing();

        public bool GetIsDrawing();

        public void SetIsDrawing(bool value);

        public bool GetCanDraw();
        public void SetCanDraw(bool value);
        
        public bool TryCastWithPrevisualisableData(int[] targetsEntityIndexes, Vector3[] targetPositions, params object[] previsualisableData);

        public object[] GetPrevisualisableData();

        public bool GetCanSkipDrawing();

        public void SetCanSkipDrawing(bool value);
    }
}
