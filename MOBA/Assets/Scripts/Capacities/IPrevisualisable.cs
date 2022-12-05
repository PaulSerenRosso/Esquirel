namespace Entities.Capacities
{
    public interface IPrevisualisable
    {
        public void EnableDrawing();

        public void DisableDrawing();

        public bool GetIsDrawing();

        public void SetIsDrawing(bool value);
    }
}
