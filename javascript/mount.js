import React from "react";
import ReactDOM from "react-dom/client";

export default function mount(components) {
  document.addEventListener("turbo:load", () => {
    const mountPoints = document.querySelectorAll("[data-react-component]");
    mountPoints.forEach((mountPoint) => {
      const { dataset } = mountPoint;
      const componentName = dataset.reactComponent;
      if (componentName) {
        const Component = components[componentName];
        if (Component) {
          const root = ReactDOM.createRoot(mountPoint);
          if (dataset.props) {
            const props = JSON.parse(dataset.props);
            root.render(<Component {...props} />);
            delete mountPoint.dataset.props;
          } else {
            root.render(<Component />);
          }
          delete mountPoint.dataset.reactComponent;
        } else {
          console.warn(
            "WARNING: No component found for: ",
            dataset.reactComponent,
            components
          );
        }
      }
    });
  });
}
