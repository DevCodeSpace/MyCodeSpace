import { TiltedCard } from "../ui/TiltedCard";
import { BlurFade } from "../ui/BlurFade";

const GALLERY_ITEMS = [
  {
    id: 1,
    title: "Mountain Retreat",
    description: "Architectural visualization",
    image:
      "https://images.unsplash.com/photo-1518780664697-55e3ad937233?q=80&w=1000&auto=format&fit=crop",
  },
  {
    id: 2,
    title: "Urban Photography",
    description: "City life in monochrome",
    image:
      "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?q=80&w=1000&auto=format&fit=crop",
  },
  {
    id: 3,
    title: "Abstract Art",
    description: "Digital composition series",
    image:
      "https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=1000&auto=format&fit=crop",
  },
];

const ShowcaseGallery = () => {
  return (
    <section className="space-y-8">
      <div className="text-center space-y-2">
        <h2 className="text-3xl font-bold tracking-tight">
          Featured Collection
        </h2>
        <p className="text-muted-foreground">
          Explore our latest curated visual experiences
        </p>
      </div>

      {/* <div className="grid grid-cols-1 md:grid-cols-3 gap-8 place-items-center">
        {GALLERY_ITEMS.map((item, idx) => (
          <BlurFade key={item.id} delay={0.2 * idx} inView>
            <TiltedCard
              captionText={item.title}
              containerClassName="w-[300px] h-[400px]"
              className="w-full h-full rounded-xl overflow-hidden shadow-xl"
              showTooltip={true}
              scaleOnHover={1.05}
              rotateAmplitude={12}
              showSpotlight={true}
            >
              <div className="relative w-full h-full bg-black">
                <img
                  src={item.image}
                  alt={item.title}
                  className="w-full h-full object-cover"
                />
                <div className="absolute bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-black/80 to-transparent">
                  <h3 className="text-white font-semibold text-lg">
                    {item.title}
                  </h3>
                  <p className="text-white/70 text-sm">{item.description}</p>
                </div>
              </div>
            </TiltedCard>
          </BlurFade>
        ))}
      </div> */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {GALLERY_ITEMS.map((item, idx) => (
          <BlurFade key={item.id} delay={0.2 * idx} inView>
            <TiltedCard
              captionText={item.title}
              containerClassName="w-full max-w-[280px] h-[360px]"
              className="w-full h-full rounded-xl overflow-hidden shadow-xl"
              showTooltip
              scaleOnHover={1.05}
              rotateAmplitude={12}
              showSpotlight
            >
              <div className="relative w-full h-full bg-black">
                <img
                  src={item.image}
                  alt={item.title}
                  className="w-full h-full object-cover"
                />
                <div className="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-black/80 to-transparent">
                  <h3 className="text-white font-semibold text-md">
                    {item.title}
                  </h3>
                  <p className="text-white/70 text-sm">{item.description}</p>
                </div>
              </div>
            </TiltedCard>
          </BlurFade>
        ))}
      </div>
    </section>
  );
};

export default ShowcaseGallery;
