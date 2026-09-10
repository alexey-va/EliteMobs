package com.magmaguy.elitemobs.utils;


import org.bukkit.inventory.ItemStack;
import org.bukkit.util.io.BukkitObjectInputStream;
import org.bukkit.util.io.BukkitObjectOutputStream;
import java.io.*;
import java.util.Base64;
import java.nio.ByteBuffer;

public class ObjectSerializer {

    private ObjectSerializer() {
    }

    /**
     * Read the object from Base64 string.
     */
    public static Object fromString(String s) throws IOException,
            ClassNotFoundException {
        if (s.length() > 22_369_624) throw new IOException("Legacy player data exceeds 16 MiB");
        byte[] data = Base64.getDecoder().decode(s);
        try (ObjectInputStream input = new LegacyPlayerDataInputStream(new DescriptorInput(data))) {
            input.setObjectInputFilter(ObjectSerializer::filterLegacyClass);
            return input.readObject();
        }
    }

    /**
     * Old releases used automatically generated UIDs. Repair the UID only when ObjectInputStream
     * is at a real class descriptor. Keep its original fields/flags so Java can map compatible
     * historical fields by name; substituting the local descriptor misreads different layouts.
     */
    private static final class LegacyPlayerDataInputStream extends ObjectInputStream {
        private final DescriptorInput source;

        private LegacyPlayerDataInputStream(DescriptorInput input) throws IOException {
            super(input);
            source = input;
        }

        @Override
        protected ObjectStreamClass readClassDescriptor() throws IOException, ClassNotFoundException {
            source.repairDescriptorUid();
            return super.readClassDescriptor();
        }
    }

    private static final class DescriptorInput extends ByteArrayInputStream {
        private DescriptorInput(byte[] data) {
            super(data);
        }

        private void repairDescriptorUid() throws IOException, ClassNotFoundException {
            // The JDK consumes TC_CLASSDESC before invoking readClassDescriptor, in non-block mode.
            // Assert that boundary rather than searching ahead into arbitrary object contents.
            if (pos < 1 || buf[pos - 1] != ObjectStreamConstants.TC_CLASSDESC)
                throw new StreamCorruptedException("Unexpected class descriptor boundary");
            DataInputStream header = new DataInputStream(new ByteArrayInputStream(buf, pos, count - pos));
            String name = header.readUTF();
            long storedUid = header.readLong();
            if (!name.startsWith("com.magmaguy.elitemobs.quests.")
                    && !name.startsWith("com.magmaguy.elitemobs.items.customloottable.")) return;
            Class<?> type = Class.forName(name, false, ObjectSerializer.class.getClassLoader());
            ObjectStreamClass local = ObjectStreamClass.lookup(type);
            if (local == null || storedUid == local.getSerialVersionUID()) return;
            try {
                type.getDeclaredField("serialVersionUID");
                return; // Preserve explicit compatibility contracts.
            } catch (NoSuchFieldException ignored) {
                // Only automatically generated historical UIDs need repair.
            }
            int nameBytes = (Byte.toUnsignedInt(buf[pos]) << 8) | Byte.toUnsignedInt(buf[pos + 1]);
            ByteBuffer.wrap(buf, pos + Short.BYTES + nameBytes, Long.BYTES).putLong(local.getSerialVersionUID());
        }
    }

    private static ObjectInputFilter.Status filterLegacyClass(ObjectInputFilter.FilterInfo info) {
        if (info.depth() > 100 || info.references() > 100_000 || info.streamBytes() > 16_777_216
                || info.arrayLength() > 1_000_000)
            return ObjectInputFilter.Status.REJECTED;
        Class<?> type = info.serialClass();
        if (type == null) return ObjectInputFilter.Status.UNDECIDED;
        while (type.isArray()) type = type.getComponentType();
        if (type.isPrimitive()) return ObjectInputFilter.Status.ALLOWED;
        String name = type.getName();
        if (name.startsWith("com.magmaguy.elitemobs.") || name.startsWith("java.lang.")
                || name.startsWith("java.util.") || name.startsWith("org.bukkit."))
            return ObjectInputFilter.Status.ALLOWED;
        return ObjectInputFilter.Status.REJECTED;
    }

    /**
     * Write the object to a Base64 string.
     */
    public static String toString(Serializable o) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ObjectOutputStream oos = new ObjectOutputStream(baos);
        oos.writeObject(o);
        oos.close();
        return Base64.getEncoder().encodeToString(baos.toByteArray());
    }

    /**
     * A method to serialize an {@link ItemStack} array to Base64 String.
     * <p>
     * <p/>
     *
     * @param itemStack to turn into a Base64 String.
     * @return Base64 string of the items.
     * @throws IllegalStateException
     */
    public static String itemStackArrayToBase64(ItemStack itemStack) throws IllegalStateException {
        try {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            BukkitObjectOutputStream dataOutput = new BukkitObjectOutputStream(outputStream);

            // Write the size of the inventory
            //dataOutput.writeInt(1);
            dataOutput.writeObject(itemStack);

            // Serialize that array
            dataOutput.close();
            return Base64.getMimeEncoder().encodeToString(outputStream.toByteArray());
        } catch (Exception e) {
            throw new IllegalStateException("Unable to save item stacks.", e);
        }
    }

    /**
     * Gets an array of ItemStacks from Base64 string.
     * <p>
     * <p/>
     *
     * @param data Base64 string to convert to ItemStack array.
     * @return ItemStack array created from the Base64 string.
     * @throws IOException
     */
    public static ItemStack itemStackArrayFromBase64(String data) throws IOException {
        try {
            ByteArrayInputStream inputStream = new ByteArrayInputStream(Base64.getMimeDecoder().decode(data));
            BukkitObjectInputStream dataInput = new BukkitObjectInputStream(inputStream);
            ItemStack itemStack = (ItemStack) dataInput.readObject();
            dataInput.close();
            return itemStack;
        } catch (ClassNotFoundException e) {
            throw new IOException("Unable to decode class type.", e);
        }
    }

}
