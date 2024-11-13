

const Sidebar = () => {
  return (
    <div className="sidebar bg-card text-card-foreground p-4">
      <h2 className="text-lg font-bold">Sidebar</h2>
      <ul>
        <li className="py-2"><a href="#home">Home</a></li>
        <li className="py-2"><a href="#about">About</a></li>
        <li className="py-2"><a href="#contact">Contact</a></li>
      </ul>
    </div>
  );
};

export default Sidebar;