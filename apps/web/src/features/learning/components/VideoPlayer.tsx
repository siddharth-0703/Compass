import { useDictionary } from "@/components/providers/DictionaryProvider";

interface VideoPlayerProps {
  videoId?: string;
  title: string;
}

export function VideoPlayer({ videoId, title }: VideoPlayerProps) {
  const { dict } = useDictionary();
  const t = dict.learningHub || {};
  // If no real video is provided or it's a placeholder, render a mock player
  const isPlaceholder = !videoId || videoId.startsWith("PLACEHOLDER");

  return (
    <div className="rounded-2xl overflow-hidden border border-white/10 bg-black aspect-video relative shadow-2xl flex items-center justify-center">
      {isPlaceholder ? (
        <div className="text-center p-6 bg-muted/20 w-full h-full flex flex-col items-center justify-center">
          <div className="w-16 h-16 rounded-full bg-primary/20 flex items-center justify-center mb-4">
             <span className="text-primary font-bold text-2xl">►</span>
          </div>
          <h3 className="text-xl font-bold mb-2">{t.videoPlaceholderTitle || "Video Player Placeholder"}</h3>
          <p className="text-muted-foreground mb-4">ID: <code className="bg-muted px-2 py-1 rounded text-sm">{videoId || "No ID"}</code></p>
          <p className="text-xs text-muted-foreground">{t.videoPlaceholderDesc || "This is a mock player for LMS architecture validation."}</p>
        </div>
      ) : (
        <iframe 
          width="100%" 
          height="100%" 
          src={`https://www.youtube.com/embed/${videoId}?autoplay=1&rel=0`} 
          title={title}
          frameBorder="0" 
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
          allowFullScreen
          className="absolute inset-0"
        />
      )}
    </div>
  );
}
